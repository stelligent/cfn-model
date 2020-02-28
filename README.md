[![cfn_model](https://github.com/stelligent/cfn-model/workflows/cfn_model/badge.svg)](https://github.com/stelligent/cfn-model/actions?query=workflow%3Acfn_model) [![VS Code DockerHub Build & Push](https://github.com/stelligent/cfn-model/workflows/VS%20Code%20DockerHub%20Build%20&%20Push/badge.svg)](https://github.com/stelligent/cfn-model/actions?query=workflow%3A%22VS+Code+DockerHub+Build+%26+Push%22)

# Overview

The cfn-model gem attempts to provide an object model to simplify doing rudimentary static analysis on CloudFormation 
templates.

It is "easy" to parse a CloudFormation template, because all (valid) templates are YAML (including the JSON templates).
On the other hand, there are a good number of situations where values can be lists or maps, or fields can be optional.
It is painful to account for some of these variations when developing static analysis code/rules.  The cyclomatic
complexity can increase and the logic can be error prone and repetitive.

cfn-model attempts to insulate rule developers from having to worry about some of the uninteresting nitty-gritty of the
structure of a CloudFormation template.  A few examples:
 
* In the case where a value can be a Hash or an Array, an Array (of the Hash) is always returned so that a rule developer can use simple enumerators and reduce cyclomatic complexity in the rule.
* Properties field/values are mapped to be instance variables of the resource objects - no worrying about a missing Properties
* The basic required structure of the CloudFormation template is validated so a rule developer can presume required fields are present (i.e. it will fail before handing out a broken object model)

The cfn-model should *not* be considered a full-fledged parser for CloudFormation templates.  It tries to parse
only enough to enable rule developers to have an easier time.  If there are items in a template that the parser
doesn't recognize, the typical behavior is to ignore it.

Some of this code comes from the internals of cfn-nag but more importantly the inspiration for this approach comes 
from difficulties in writing cfn-nag rules.

# Usage

The primary interface point for this gem is the `CfnParser` which can generate a `CfnModel` object
upon which static analysis can be conducted.

The `CfnModel` is a container for other object that have been parsed, wrapped and potentially linked to
other wrapped objects.

The raw Hash output of `YAML.load` is also available from `CfnModel`.

    require 'cfn-model'
        
    cfn_model = CfnParser.parse IO.read('some_cloudformation_template.yml')
    
    cfn_model.resources_by_type('AWS::IAM::User').each do |iam_user|
       # interrogate the iam_user
    end

## With Line Number Tracking

    require 'cfn-model'

    cfn_model = CfnParser.parse IO.read('some_cloudformation_template.yml'), nil, true

    cfn_model.resources_by_type('AWS::IAM::User').each do |iam_user|
       # interrogate the iam_user
    ende

## Built-in Model Elements
    
## Unanticipated Model Elements

For any resource type that cfn-model doesn't recognize, it will still add an object with the Properties fields flattened
down as instance variables on the generated object.  Given it's not recognized, there won't be any special parsing, wrapping
or linking of the object.

For example, parsing the CloudFormation template:

      ---
      Resources:
        newResource:
          Type: "AWS::TimeTravel::Machine"
          Properties:
            Fuel: dilithium

would yield an object: 

      time_travel_machine = cfn_model.resources_by_type('AWS::TimeTravel::Machine').first
      expect(time_travel_machine.fuel).to eq 'dilithium'
      
# Development

## Specs

To run the specs, you need to ensure you have Docker installed and cfn-model dependencies installed via
```
gem install bundle
bundle install
```

Then, to run all of the specs, just run `rake spec`.

## VS Code Remote Development
There is a complete remote development environment created and setup with all the tools and settings pre-configured for ease in rule development and creation. You can enable this by using the VS Code Remote development functionality.

- Install the VS Code [Remote Development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
- Open the repo in VS Code
- When prompted "`Folder contains a dev container configuration file. Reopen folder to develop in a container`" click the "`Reopen in Container`" button
- When opening in the future use the "`[Dev Container] cfn_nag Development`" option

More information about the VS Code Remote Development setup can be found here, [VS Code Remote Development](vscode_remote_development.md).

# Support

To report a bug or request a feature, submit an issue through the GitHub repository via: <https://github.com/stelligent/cfn-model/issues/new>

# Deeper Dive

## Parsing

## Validation

## Adding a Model Element type    

## Unanticipated Resource Types

# Open issues

* Need to ponder a more general treatment for Refs 
* Interesting to ponder doing analysis against a template combined with externally supplied Parameter values
* Required attributes keep becoming optional... need to find way to bring validation in line with authoritative rules
* Need to ponder best way to redesign to deal with macros and such
