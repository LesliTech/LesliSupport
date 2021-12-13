=begin

Copyright (c) 2021, all rights reserved.

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

module CloudHelp
    module Reports
        class StyleService
            include ::Reports::Helper

            def self.tickets_general
                return {
                    styles: {
                        bold_only: {b: true},
                        italic_only: {i: true},
                        date: {format_code: date_format},
                        datetime: {format_code: datetime_format},
                        header: {fg_color: "ffffff", bg_color: "209cee", alignment: {wrap_text: true}},
                        wrap_text: {alignment: {wrap_text: true, horizontal: :left}},
                        number: {format_code: "#.00"},
                        title: {b:true, alignment: {horizontal: :center, vertical: :center}, sz: 14}
                    },
                    sheets: [{
                        widths: [10, nil],
                        rows: [
                            {end_row: 0, columns: [{style_name: :header}]},
                            columns: [
                                {end_column: 0, style_name: :wrap_text},
                                {end_column: 1, style_name: :datetime},
                                {end_column: 3, style_name: :wrap_text},
                                {end_column: 4, style_name: :date},
                                {end_column: 10, style_name: :wrap_text},
                                {end_column: 11, style_name: :number}
                            ]
                        ] 
                    }]
                }
            end
        end
    end
end
