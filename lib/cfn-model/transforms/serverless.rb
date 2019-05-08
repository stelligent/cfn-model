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

      # Is a URL a S3 URL
      def is_s3_uri?(uri)
        !uri.nil? and uri[0..4].eql? 's3://'
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength

      def replace_serverless_function(cfn_hash, resource_name)
        resource = cfn_hash['Resources'][resource_name]
        code_uri = resource['Properties']['CodeUri']

        lambda_fn_params = {
          handler: resource['Properties']['Handler'],
          runtime: resource['Properties']['Runtime']
        }
        if is_s3_uri? code_uri
          lambda_fn_params[:code_bucket] = bucket_from_uri code_uri
          lambda_fn_params[:code_key] = object_key_from_uri code_uri
        end
        cfn_hash['Resources'][resource_name] = \
          lambda_function lambda_fn_params

        cfn_hash['Resources']['FunctionNameRole'] = function_name_role
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength

      # Return the hash structure of the 'FunctionNameRole'
      # AWS::IAM::Role resource as created by Serverless transform
      def function_name_role
        {
          'Type' => 'AWS::IAM::Role',
          'Properties' => {
            'ManagedPolicyArns' =>
            ['arn:aws:iam::aws:policy/service-role/' \
              'AWSLambdaBasicExecutionRole'],
            'AssumeRolePolicyDocument' => {
              'Version' => '2012-10-17',
              'Statement' => [{
                'Action' => ['sts:AssumeRole'], 'Effect' => 'Allow',
                'Principal' => { 'Service' => ['lambda.amazonaws.com'] }
              }]
            }
          }
        }
      end
      # rubocop:enable Metrics/MethodLength

      # Return the hash structure of a AWS::Lambda::Function as created
      # by Serverless transform
      def lambda_function(handler:,
                          code_bucket: nil,
                          code_key: nil,
                          runtime:)
        fn_resource = \
        { 'Type' => 'AWS::Lambda::Function',
          'Properties' => {
            'Handler' => handler,
            'Role' => { 'Fn::GetAtt' => %w[FunctionNameRole Arn] },
            'Runtime' => runtime
          } }
        if code_bucket && code_key
          fn_resource['Properties']['Code'] = {
            'S3Bucket' => code_bucket,
            'S3Key' => code_key
          }
        end
        fn_resource
      end
    end
  end
end
