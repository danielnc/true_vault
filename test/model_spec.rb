require_relative "spec_helper"

describe TrueVault::Model do
  # TODO add tests
  describe "create!" do
    describe "index exists" do
      # before { Patient.true_vault_index.create! }
      # after { Patient.true_vault_index.delete! }

      it "raise error" do
        # skip("Still need to add tests")
        # a = Patient.create(first_name: "First", last_name: "Last", birth_date: 10.years.ago.to_date, enabled: true, income: 1000, latitude: 123456.789, longitude: 987654.321)

        # 3bf5e4cb-4bcb-4161-a8c3-e14b9561056e
        # 0a00c0d4-d6e0-4723-8fc2-174a7e8f04e0
        # puts TrueVault::REST::API.get_document("18dd7b94-bea4-4587-90fe-4e8e5ff422c0")
        # puts Patient.true_vault_index.update!


        # puts Patient.search({last_name: {value: "Last", wildcard: true}}, {sort: {created_at: :asc}, case_insensitive: true}).inspect
        # puts Patient.search({last_name: {value: "ast", ends_with: true}}, {sort: {created_at: :asc}}).inspect
        # puts Patient.true_vault_search({full_name: {value: "*last*", wildcard: true}}, {sort: {created_at: :asc}, case_insensitive: true}).inspect
      end
    end
  end

  describe "update!" do
    it "updates the record" do
      Patient.create(first_name: "First", last_name: "Last00100100", birth_date: 10.years.ago.to_date, enabled: true, income: 1000, latitude: 123456.789, longitude: 987654.321)
      Patient.create(first_name: "First", last_name: "Last00100200", birth_date: 20.years.ago.to_date, enabled: true, income: 2000, latitude: 123456.789, longitude: 987654.321)
      Patient.create(first_name: "First", last_name: "Last00100300", birth_date: 20.years.ago.to_date, enabled: true, income: 3000, latitude: 123456.789, longitude: 987654.321)
      Patient.create(first_name: "First", last_name: "Last00100400", birth_date: 30.years.ago.to_date, enabled: true, income: 2000, latitude: 123456.789, longitude: 987654.321)
      Patient.create(first_name: "First1", last_name: "Last01000400", birth_date: 10.years.ago.to_date, enabled: true, income: 1000, latitude: 123456.789, longitude: 987654.321)
      Patient.create(first_name: "First2", last_name: "Last01000400", birth_date: 30.years.ago.to_date, enabled: true, income: 4000, latitude: 123456.789, longitude: 987654.321)
      Patient.create(first_name: "First3", last_name: "Last01000400", birth_date: 10.years.ago.to_date, enabled: true, income: 1000, latitude: 123456.789, longitude: 987654.321)
      puts Patient.true_vault_search({last_name: {value: "Last01000*", wildcard: true}, birth_date: {value: [11.years.ago.to_date, 21.years.ago.to_date], range: true}, first_name: %w(First First1)}, {sort: {last_name: :asc, first_name: :desc}}).to_a.map { |p| "#{p.first_name} #{p.last_name} - #{p.birth_date}" }.inspect
    end
  end
  describe "delete!" do
    it "deletes the record" do
      # a = Patient.create(first_name: "First", last_name: "Last7", birth_date: 10.years.ago.to_date, enabled: true, income: 1000, latitude: 123456.789, longitude: 987654.321)
      # a.true_vault_document_id = '12312391020'
      # puts Patient.true_vault_search({last_name: "Last7"}).inspect
      # a.destroy
      # puts Patient.true_vault_search({last_name: "Last7"}).inspect
    end
  end
  describe "exists?" do
    it "checks if record exists" do
      # a = Patient.create(first_name: "First", last_name: "Last7", birth_date: 10.years.ago.to_date, enabled: true, income: 1000, latitude: 123456.789, longitude: 987654.321)
    #   p a.send(:true_vault_model).exists?
    end
  end
end