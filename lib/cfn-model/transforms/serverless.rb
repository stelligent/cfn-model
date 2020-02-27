# frozen_string_literal: true

class CfnModel
  class Transforms
    # Handle transformation of model elements performed by the
    # Serverless trasnform, see
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/transform-aws-serverless.html
    class Serverless
      def perform_transform(cfn_hash)
        with_line_numbers = false
        resources = cfn_hash['Resources'].clone
        resources.each do |resource_name, resource|
          next unless matching_resource_type?(resource['Type'], 'AWS::Serverless::Function')

          with_line_numbers = true if resource['Type'].is_a? Hash
          replace_serverless_function cfn_hash, resource_name, with_line_numbers
        end
      end

      def self.instance
        @instance ||= Serverless.new
        @instance
      end

      private

      # Bucket is 3rd element of an S3 URI split on '/'
      def bucket_from_uri(uri)
        uri.split('/')[2]
      end

      # Object key is 4th element to end of an S3 URI split on '/'
      def object_key_from_uri(uri)
        uri.split('/')[3..-1].join('/')
      end

      def s3_uri?(uri)
        if uri.is_a? String
          uri[0..4].eql? 's3://'
        else
          false
        end
      end

      def matching_resource_type?(resource_type, type_to_match)
        matching_string_resource_type?(resource_type, type_to_match) ||
          matching_line_number_enriched_resource_type?(resource_type, type_to_match)
      end

      def matching_string_resource_type?(resource_type, type_to_match)
        resource_type.is_a?(String) && resource_type.eql?(type_to_match)
      end

      def matching_line_number_enriched_resource_type?(resource_type, type_to_match)
        resource_type.is_a?(Hash) && resource_type['value'].eql?(type_to_match)
      end

      def format_resource_type(type, line_no, numbers)
        numbers ? { 'value' => type, 'line' => line_no } : type
      end

      def resolve_globals_function_property(cfn_hash, property_name)
        cfn_hash['Globals'] && cfn_hash['Globals']['Function'] && cfn_hash['Globals']['Function'][property_name]
      end

      def serverless_function_property(serverless_function, cfn_hash, property_name)
        serverless_function['Properties'][property_name] || \
          resolve_globals_function_property(cfn_hash, property_name)
      end

      def format_function_role(serverless_function, function_name)
        getatt_hash = { 'Fn::GetAtt' => ["#{function_name}Role", 'Arn'] }
        serverless_function['Properties']['Role'] || getatt_hash
      end

      # i question whether we need to carry out the transform this far given cfn_nag
      # likely won't ever opine on bucket names or object keys
      def transform_code_uri(lambda_fn_params, code_uri)
        if s3_uri? code_uri
          lambda_fn_params[:code_bucket] = bucket_from_uri code_uri
          lambda_fn_params[:code_key] = object_key_from_uri code_uri
        elsif code_uri.is_a? Hash
          lambda_fn_params[:code_bucket] = code_uri['Bucket']
          lambda_fn_params[:code_key] = code_uri['Key']
        end
        lambda_fn_params
      end

      def serverless_function_properties(cfn_hash, serverless_function, fn_name, with_line_numbers)
        code_uri = serverless_function_property(serverless_function, cfn_hash, 'CodeUri')

        lambda_fn_params = {
          handler: serverless_function_property(serverless_function, cfn_hash, 'Handler'),
          role: format_function_role(serverless_function, fn_name),
          runtime: serverless_function_property(serverless_function, cfn_hash, 'Runtime'),
          with_line_numbers: with_line_numbers
        }

        lambda_fn_params = transform_code_uri(
          lambda_fn_params,
          code_uri
        )

        lambda_fn_params
      end

      def replace_serverless_function(cfn_hash, resource_name, with_line_numbers)
        serverless_function = cfn_hash['Resources'][resource_name]

        lambda_fn_params = serverless_function_properties(cfn_hash,
                                                          serverless_function,
                                                          resource_name,
                                                          with_line_numbers)

        cfn_hash['Resources'][resource_name] = lambda_function lambda_fn_params

        unless serverless_function['Properties']['Role']
          cfn_hash['Resources'][resource_name + 'Role'] = function_role(serverless_function,
                                                                        resource_name,
                                                                        with_line_numbers)
        end

        transform_function_events(cfn_hash, serverless_function, resource_name, with_line_numbers) if \
          serverless_function['Properties']['Events']
      end

      def lambda_service_can_assume_role
        {
          'Version' => '2012-10-17',
          'Statement' => [
            {
              'Action' => ['sts:AssumeRole'],
              'Effect' => 'Allow',
              'Principal' => { 'Service' => ['lambda.amazonaws.com'] }
            }
          ]
        }
      end

      # Return the hash structure of the '<function_name>Role'
      # AWS::IAM::Role resource as created by Serverless transform
      def function_role(serverless_function, function_name, with_line_numbers)
        fn_role = {
          'Type' => format_resource_type('AWS::IAM::Role', -1, with_line_numbers),
          'Properties' => {
            'ManagedPolicyArns' => function_role_managed_policies(serverless_function['Properties']),
            'AssumeRolePolicyDocument' => lambda_service_can_assume_role
          }
        }
        function_role_policies(fn_role, serverless_function['Properties'], function_name)
        fn_role
      end

      def function_role_managed_policies(function_properties)
        # Always set AWSLambdaBasicExecutionRole policy
        base_policies = ['arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole']

        # Return base_policies if no policies assigned to the function
        return base_policies unless function_properties['Policies']

        # If the SAM function Policies property is a string, append and return
        return base_policies | ["arn:aws:iam::aws:policy/#{function_properties['Policies']}"] if \
          function_properties['Policies'].is_a? String

        # Iterate on Policies property and add if String
        policy_names = function_properties['Policies'].select { |policy| policy.is_a? String }
        base_policies | policy_names.map { |name| "arn:aws:iam::aws:policy/#{name}" }
      end

      def function_role_policies(role, function_properties, fn_name)
        # Return if no policies assigned to the function
        return unless function_properties['Policies']

        # Process inline policies from SAM function
        return if function_properties['Policies'].is_a? String

        # Iterate on Policies property and add if Hash
        policy_hashes = function_properties['Policies'].select do |policy|
          policy.is_a?(Hash) && policy.keys.first !~ /Policy/
        end
        return if policy_hashes.empty?

        # Create policy documents
        policy_documents = policy_hashes.map.with_index do |policy, index|
          {
            'PolicyDocument' => policy,
            'PolicyName' => "#{fn_name}RolePolicy#{index}"
          }
        end

        role['Properties']['Policies'] = policy_documents
      end

      def lambda_function_code(fn_resource, code_bucket, code_key)
        if code_bucket && code_key
          fn_resource['Properties']['Code'] = {
            'S3Bucket' => code_bucket,
            'S3Key' => code_key
          }
        end
        fn_resource
      end

      # Return the hash structure of a AWS::Lambda::Function as created
      # by Serverless transform
      def lambda_function(handler:,
                          code_bucket: nil,
                          code_key: nil,
                          role:,
                          runtime:,
                          with_line_numbers: false)
        fn_resource = {
          'Type' => format_resource_type('AWS::Lambda::Function', -1, with_line_numbers),
          'Properties' => {
            'Handler' => handler,
            'Role' => role,
            'Runtime' => runtime
          }
        }
        lambda_function_code(fn_resource, code_bucket, code_key)
      end

      # Return the Event structure of a AWS::Lambda::Function as created
      # by Serverless transform
      def transform_function_events(cfn_hash, serverless_function, function_name, with_line_numbers)
        serverless_function['Properties']['Events'].each do |_, event|
          serverlessrestapi_resources(cfn_hash, event, function_name, with_line_numbers) if \
            matching_resource_type?(event['Type'], 'Api')
        end
      end

      def serverlessrestapi_resources(cfn_hash, event, func_name, with_line_numbers)
        # ServerlessRestApi
        cfn_hash['Resources']['ServerlessRestApi'] ||= serverlessrestapi_base with_line_numbers
        add_serverlessrestapi_event(
          cfn_hash['Resources']['ServerlessRestApi']['Properties']['Body']['paths'],
          event,
          func_name
        )

        # ServerlessRestApiDeployment
        cfn_hash['Resources']['ServerlessRestApiDeployment'] = serverlessrestapi_deployment with_line_numbers

        # ServerlessRestApiProdStage
        cfn_hash['Resources']['ServerlessRestApiProdStage'] = serverlessrestapi_stage with_line_numbers
      end

      def serverlessrestapi_base(with_line_nos)
        {
          'Type' => format_resource_type('AWS::ApiGateway::RestApi', -1, with_line_nos),
          'Properties' => {
            'Body' => {
              'info' => {
                'title' => { 'Ref' => 'AWS::StackName' },
                'version' => '1.0'
              },
              'paths' => {},
              'swagger' => '2.0'
            }
          }
        }
      end

      def add_serverlessrestapi_event(paths_hash, event, function_name)
        paths_hash[event['Properties']['Path']] = {
          event['Properties']['Method'] => {
            'responses' => {},
            'x-amazon-apigateway-integration' => {
              'httpMethod' => 'POST',
              'type' => 'aws_proxy',
              'uri' => { 'Fn::Sub' => "arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${#{function_name}.Arn}/invocations" }
            }
          }
        }
      end

      def serverlessrestapi_deployment(with_line_nos)
        {
          'Type' => format_resource_type('AWS::ApiGateway::Deployment', -1, with_line_nos),
          'Properties' => {
            'Description' => 'Generated by cfn-model',
            'RestApiId' => { 'Ref' => 'ServerlessRestApi' },
            'StageDescription' => {
              'AccessLogSetting' => {
                'DestinationArn' => 'arn:aws:logs:region:account:group/ApiLogs',
                'Format' => '$context.requestId'
              }
            },
            'StageName' => 'Stage'
          }
        }
      end

      def serverlessrestapi_stage(with_line_nos)
        {
          'Type' => format_resource_type('AWS::ApiGateway::Stage', -1, with_line_nos),
          'Properties' => {
            'DeploymentId' => { 'Ref' => 'ServerlessRestApiDeployment' },
            'RestApiId' => { 'Ref' => 'ServerlessRestApi' },
            'StageName' => 'Prod'
          }
        }
      end
    end
  end
end
