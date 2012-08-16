class IdConvert
  def self.run
    licence_mappings = CSV.read("data/licence_mappings.csv", headers: true)
    revised_codes = CSV.read("data/revised_codes.csv", headers: true)
    match = 0
    in_db = 0
    correlation_to_gds_id = {}
    CSV.open("data/missing_legal_ref.csv", "wb") do |missing_legal_ref_csv|
      missing_legal_ref_csv << revised_codes.headers
      CSV.open("data/missing_in_db.csv", "wb") do |missing_in_db_csv|
        missing_in_db_csv << revised_codes.headers
        revised_codes.each do |row|
          legal_ref_num = row["legal ref nr"]
          result = licence_mappings.find{|i| i["Legal_Ref_No"] == legal_ref_num}
          if result
            match += 1
            correlation_id = result["GDS ID"]
            correlation_to_gds_id[correlation_id] = row["New code?"]
            licence = Licence.find_by_correlation_id(correlation_id)
            if licence
              in_db += 1
            else
              missing_in_db_csv << row
            end
          else
            missing_legal_ref_csv << row
          end
        end
      end
    end

    # puts correlation_to_gds_id.inspect
    puts "Matched #{match}/#{revised_codes.count}"
    puts "In db   #{in_db}/#{match}"
  end
end