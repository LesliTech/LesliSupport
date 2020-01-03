module CloudHelp
    class TicketCategory < ApplicationRecord
        acts_as_tree

        belongs_to :account, class_name: 'CloudHelp::Account', foreign_key: 'cloud_help_accounts_id'

        has_many :details, class_name: 'CloudHelp::Ticket::Detail', foreign_key: 'cloud_help_ticket_categories_id'
        has_many :workflows, class_name: 'CloudHelp::TicketWorkflow',  foreign_key: 'cloud_help_ticket_categories_id', dependent: :destroy

        # Gets the path of the current node in tree style
        def tree
            data = []
            depth = 0
            path.each do |node|
                if node.id == id
                    data.push(node.attributes.merge({
                        'has_children'=>false,
                        'active'=>true,
                        'depth'=>depth
                    }))
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

        # Gets all records in tree style
        def self.tree(account)
            # We get the root nodes
            
            roots = account.help.ticket_categories.where(ancestry: nil).order(name: :asc)
            data = []
            roots.each_with_index do |root|
                data.concat(self.tree_recursion(root, true))
            end
            data
        end

        def destroy
            begin
                super
            rescue ActiveRecord::InvalidForeignKey, ActiveRecord::StatementInvalid
                errors.add(:base, :foreign_key_prevents_destruction)
                false
            end
        end

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


        private

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
