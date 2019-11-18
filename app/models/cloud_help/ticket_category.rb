module CloudHelp
    class TicketCategory < ApplicationRecord
        acts_as_tree

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'

        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_types_id'

        def self.tree(account)
            # We get the root nodes
            
            roots = account.help.ticket_categories.where(ancestry: nil).order(name: :asc)
            data = []
            roots.each_with_index do |root,index|
                index+=1
                data.concat(self.tree_recursion(root, true, index, 0))
            end
            data
        end

        private

        def self.tree_recursion(root, is_root, index, depth)
            # leaves is the list of children. I called it differently so there would be no conflict
            leaves = []
            has_children = root.has_children?
            if has_children
                root.children.order(name: :asc).each_with_index do |child, child_index|
                    child_index+=1
                    child_data = self.tree_recursion(child, false, "#{index}.#{child_index}", depth+1)
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
                'index'=>index,
                'has_children'=>has_children,
                'active'=>is_root,
                'children_active'=>false,
                'depth'=>depth
            
            })].concat(leaves)
        end
    end
end
