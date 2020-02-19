module CloudHelp
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Model for ticket categories

=end
    class Catalog::TicketCategory < ApplicationRecord
        acts_as_tree

        belongs_to :account,    class_name: "CloudHelp::Account",   foreign_key: "cloud_help_accounts_id"
        has_many :tickets,      class_name: "CloudHelp::Ticket",    foreign_key: "cloud_help_ticket_categories_id"

        validates :name, presence: true

=begin
@return [Boolean] Wheter the ticket category was deleted or not
@description Attempts to delete this ticket category along with it's associated *workflow*.
    However, if there is a *ticket* associated to this *category*, it will not be deleted
    and an error will be added to the *errors* parameter
@example
    my_category = CloudHelp::TicketCategory.first
    if my_category.destroy
        puts "Ticket category successfully destroyed"
    else
        puts "Ticket category was not destroyed"
        puts my_category.errors.full_messages.to_sentence
    end
=end
        def destroy
            begin
                super
            rescue ActiveRecord::InvalidForeignKey, ActiveRecord::StatementInvalid
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

=begin
@return [Array] An array that contains a list of the current categories and all its parents.
@description Creates a list of categories starting from the root parent category and ending in
    the current category. If the current category is a root category, the array will have only
    one element.
@example
    current_category = CloudHelp::TicketCategory.first
    category_tree = current_category.tree
    puts category_tree.to_json
=end
        def tree
            data = []
            depth = 0
            path.each do |node|
                if node.id == id
                    node_attributes = node.attributes.merge({
                        'has_children'=>false,
                        'active'=>true,
                        'depth'=>depth
                    })

                    if node.parent
                        node_attributes = node_attributes.merge({'parent_id' => node.parent.id})
                    else
                        node_attributes = node_attributes.merge({'parent_id' => nil})
                    end

                    data.push(node_attributes)
                else
                    data.push(
                        node.attributes.slice('id','name','ancestry').merge({
                            'has_children'=>true,
                            'active'=>true,
                            'children_active'=>true,
                            'depth'=>depth
                        })
                    )
                end
                depth+=1
            end
            data
        end

        
=begin
@return [String] A text with all categories, from root to the current category, separated by commas.
@description Returns a string representation of the tree method. Where all parent categories of the
    current category appear ordered
@example
    current_category = CloudHelp::TicketCategory.first
    puts current_category.full_path # Will display something similar to "System, Admin, Sales"
=end
        def full_path
            string_path = ""
            path.each do |node|
                if string_path.empty?
                    string_path = node.name
                else
                    string_path += ", #{node.name}"
                end
            end
            string_path
        end

=begin
@param account [Account] The account of the *current_user*, used to filter the records 
@return [Array] An array that contains a list of categories ordered in a nested way.
@description Creates a list of categories. The list is ordered by parent category, 
    followed by children categories. If there are no children categories, the next 
    parent category is placed. This makes the records appear in a nested way, without being
    really nested
@example
    categories = CloudHelp::TicketCategory.tree(current_user.account)
    puts categories.to_json
=end
        def self.tree(account)
            roots = account.help.ticket_categories.where(ancestry: nil).order(name: :asc)
            data = []
            roots.each_with_index do |root|
                data.concat(self.tree_recursion(root, true))
            end
            data
        end

        protected

=begin
@param root [TicketCategory] The category taken as root
@param is_root  [Bolean] Wheter this category has a parent or not
@return [Array] An array that contains a list of categories ordered in a nested way.
@description Selects all categories that are direct children of the *root* category and adds then
    to the array, one at a time, in a recursive way (also adding the children of the children, and so on)
@example
    my_category = CloudHelp::TicketCategory.find(1)
    my_category_tree = CloudHelp::TicketCategory.tree_recursion(my_category, true)
    # will find all children of 'my_category and order them in a recursive way'
=end
        def self.tree_recursion(root, is_root)
            # leaves is the list of children. I called it differently so there would be no conflict
            leaves = []
            has_children = root.has_children?
            if has_children
                root.children.order(name: :asc).each_with_index do |child|
                    child_data = self.tree_recursion(child, false)
                    leaves.concat(child_data)
                end
            end
            [root.attributes.slice(
                'id',
                'name',
                'ancestry',
                'created_at',
                'updated_at'
            ).merge({
                'has_children'=>has_children,
                'active'=>is_root,
                'children_active'=>false,
                'depth'=>root.depth
            
            })].concat(leaves)
        end
    end
end
    