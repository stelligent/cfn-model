# frozen_string_literal: true

class CfnModel
  class Transforms
    # Handle transformation of model elements performed by the
    # Serverless trasnform, see
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/transform-aws-serverless.html
    class Serverless
      def perform_transform(cfn_hash)
        resources = cfn_hash['Resources'].clone
        resources.each do |resource_name, resource|
          next unless resource['Type'].eql? 'AWS::Serverless::Function'

          replace_serverless_function cfn_hash, resource_name
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

      def resolve_globals_function_property(cfn_hash, property_name)
        cfn_hash['Globals']['Function'][property_name]
      end

      def serverless_function_property(serverless_function, cfn_hash, property_name)
        serverless_function['Properties'][property_name] || \
          resolve_globals_function_property(cfn_hash, property_name)
      end

      # i question whether we need to carry out the transform this far given cfn_nag
      # likely won't ever opine on bucket names or object keys
      def transform_code_uri(lambda_fn_params, code_uri)
        puts code_uri
        if s3_uri? code_uri
          lambda_fn_params[:code_bucket] = bucket_from_uri code_uri
          lambda_fn_params[:code_key] = object_key_from_uri code_uri
        elsif code_uri.is_a? Hash
          lambda_fn_params[:code_bucket] = code_uri['Bucket']
          lambda_fn_params[:code_key] = code_uri['Key']
        end
        lambda_fn_params
      end

      def serverless_function_properties(cfn_hash, serverless_function)
        code_uri = serverless_function_property(serverless_function, cfn_hash, 'CodeUri')

        lambda_fn_params = {
          handler: serverless_function_property(serverless_function, cfn_hash, 'Handler'),
          runtime: serverless_function_property(serverless_function, cfn_hash, 'Runtime')
        }

        lambda_fn_params = transform_code_uri(
          lambda_fn_params,
          code_uri
        )

        lambda_fn_params
      end

      def replace_serverless_function(cfn_hash, resource_name)
        serverless_function = cfn_hash['Resources'][resource_name]

        lambda_fn_params = serverless_function_properties(cfn_hash, serverless_function)

        cfn_hash['Resources'][resource_name] = lambda_function lambda_fn_params

        cfn_hash['Resources']['FunctionNameRole'] = function_name_role
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

      # Return the hash structure of the 'FunctionNameRole'
      # AWS::IAM::Role resource as created by Serverless transform
      def function_name_role
        {
          'Type' => 'AWS::IAM::Role',
          'Properties' => {
            'ManagedPolicyArns' => [
              'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
            ],
            'AssumeRolePolicyDocument' => lambda_service_can_assume_role
          }
        }
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
                          runtime:)
        fn_resource = {
          'Type' => 'AWS::Lambda::Function',
          'Properties' => {
            'Handler' => handler,
            'Role' => { 'Fn::GetAtt' => %w[FunctionNameRole Arn] },
            'Runtime' => runtime
          }
        }
        lambda_function_code(fn_resource, code_bucket, code_key)
      end
    end
  end
end
