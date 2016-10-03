# Produces a three way mapping between the legacy BT_ID, the Legal Ref Number and the new GDS_ID
#
class IdConvert
  def self.run
    licence_mappings = CSV.read("data/licence_mappings.csv", headers: true)
    revised_codes = CSV.read("data/revised_codes.csv", headers: true)
    match = 0
    in_db = 0
    mappings_headers = %w(correlation_id legal_ref_id gds_id)
    correlation_to_gds_id = {}
    CSV.open("data/correlation_id_to_gds_id_mappings.csv", "wb") do |mappings_csv|
      mappings_csv << CSV::Row.new(mappings_headers, mappings_headers, headers: true)
      CSV.open("data/missing_legal_ref.csv", "wb") do |missing_legal_ref_csv|
        missing_legal_ref_csv << revised_codes.headers
        CSV.open("data/missing_in_db.csv", "wb") do |missing_in_db_csv|
          missing_in_db_csv << revised_codes.headers
          revised_codes.each do |row|
            legal_ref_num = row["legal ref nr"]
            result = licence_mappings.find { |i| i["Legal_Ref_No"] == legal_ref_num }
            if result
              match += 1
              correlation_id = result["GDS ID"]
              correlation_to_gds_id[correlation_id] = row["New code?"]
              licence = Licence.where(correlation_id: correlation_id).first
              if licence
                in_db += 1
                unless row["New code?"] =~ /ignore/
                  mappings_csv << CSV::Row.new(mappings_headers, [result["GDS ID"], legal_ref_num, row["New code?"]])
                end
              else
                missing_in_db_csv << row
              end
            else
              missing_legal_ref_csv << row
            end
          end
        end
      end
    end

    # puts correlation_to_gds_id.inspect
    puts "Matched #{match}/#{revised_codes.count}"
    puts "In db   #{in_db}/#{match}"
  end
end
