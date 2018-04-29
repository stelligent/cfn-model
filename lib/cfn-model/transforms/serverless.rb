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

      def bucket_from_uri(uri)
        uri.split('/')[2]
      end

      def object_key_from_uri(uri)
        uri.split('/')[3..-1].join('/')
      end

      # rubucop:disable Metrics/AbcSize
      # rubucop:disable Metrics/MethodLength

      def replace_serverless_function(cfn_hash, resource_name)
        resource = cfn_hash['Resources'][resource_name]
        # Bucket is 3rd element of an S3 URI split on '/'
        code_bucket = bucket_from_uri resource['Properties']['CodeUri']
        # Object key is 4th element to end of an S3 URI split on '/'
        code_key = object_key_from_uri resource['Properties']['CodeUri']

        cfn_hash['Resources'][resource_name] = \
          lambda_function(
            handler: resource['Properties']['Handler'],
            code_bucket: code_bucket,
            code_key: code_key,
            runtime: resource['Properties']['Runtime']
          )

        cfn_hash['Resources']['FunctionNameRole'] = function_name_role
      end

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
                'Action' => ['sts:AssumeRole'],
                'Effect' => 'Allow',
                'Principal' => {
                  'Service' => ['lambda.amazonaws.com']
                }
              }]
            }
          }
        }
      end

      # Return the hash structure of a AWS::Lambda::Function as created
      # by Serverless transform
      def lambda_function(handler:, code_bucket:, code_key:, runtime:)
        { 'Type' => 'AWS::Lambda::Function',
          'Properties' => {
            'Handler' => handler,
            'Code' => { 'S3Bucket' => code_bucket,
                        'S3Key' => code_key },
            'Role' => { 'Fn::GetAtt' => %w[FunctionNameRole Arn] },
            'Runtime' => runtime
          } }
      end
    end
  end
end
