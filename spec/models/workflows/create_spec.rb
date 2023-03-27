=begin

Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
=end


# include helpers, configuration & initializers for request tests
require "lesli_model_helper"


RSpec.describe "CloudHelp::Workflow", type: :model do

    it "is expected to create a workflow with an array of next_status" do

        workflow_params =  {
            account: ::Account.first,
            name: Faker::Lorem.word,
            deletion_protection: true,
            default: false,
            statuses_attributes: [{
                number: 1,
                name: "created",
                status_type: "initial",
                next_statuses: [1]
            }]
        } 

        workflow = CloudHelp::Workflow.new(workflow_params)
        workflow.save!

        expect(workflow.statuses.first.next_statuses).to eql("1")
    end 

    it "is expected to create a workflow with an array of next_statuses" do

        workflow_params =  {
            account: ::Account.first,
            name: Faker::Lorem.word,
            deletion_protection: true,
            default: false,
            statuses_attributes: [{
                number: 1,
                name: "created",
                status_type: "initial",
                next_statuses: [1,2]
            }]
        } 

        workflow = CloudHelp::Workflow.new(workflow_params)
        workflow.save!

        expect(workflow.statuses.first.next_statuses).to eql("1|2")
    end 

    it "is expected to create a workflow with nil as next_status" do

        workflow_params =  {
            account: ::Account.first,
            name: Faker::Lorem.word,
            deletion_protection: true,
            default: false,
            statuses_attributes: [{
                number: 1,
                name: "created",
                status_type: "initial",
                next_statuses: nil
            }]
        } 

        workflow = CloudHelp::Workflow.new(workflow_params)
        workflow.save!

        expect(workflow.statuses.first.next_statuses).to eql("")
    end 

    it "is expected to create a workflow with empty string as next_status" do

        workflow_params =  {
            account: ::Account.first,
            name: Faker::Lorem.word,
            deletion_protection: true,
            default: false,
            statuses_attributes: [{
                number: 1,
                name: "created",
                status_type: "initial",
                next_statuses: nil
            }]
        } 

        workflow = CloudHelp::Workflow.new(workflow_params)
        workflow.save!

        expect(workflow.statuses.first.next_statuses).to eql("")
    end 

    it "is expected to create a workflow with number as next_status" do

        workflow_params =  {
            account: ::Account.first,
            name: Faker::Lorem.word,
            deletion_protection: true,
            default: false,
            statuses_attributes: [{
                number: 1,
                name: "created",
                status_type: "initial",
                next_statuses: 1
            }]
        } 

        workflow = CloudHelp::Workflow.new(workflow_params)
        workflow.save!

        expect(workflow.statuses.first.next_statuses).to eql("1")
    end 
end
