require_relative "spec_helper"

describe TrueVault::Model do
  # TODO add tests
  describe "create!" do
    describe "index exists" do
      # before { Patient.true_vault_index.create! }
      # after { Patient.true_vault_index.delete! }

      it "raise error" do
        skip("Still need to add tests")
        # Patient.create(first_name: "First", last_name: "Last", birth_date: 10.years.ago.to_date, enabled: true, income: 1000, latitude: 123456.789, longitude: 987654.321)
        # 3bf5e4cb-4bcb-4161-a8c3-e14b9561056e
        # 0a00c0d4-d6e0-4723-8fc2-174a7e8f04e0
        # puts TrueVault::REST::API.get_document("18dd7b94-bea4-4587-90fe-4e8e5ff422c0")
        # puts Patient.true_vault_index.update!


        # puts Patient.search({last_name: {value: "last", starts_with: true}}, {sort: {created_at: :asc}, case_insensitive: true}).inspect
        # puts Patient.search({last_name: {value: "ast", ends_with: true}}, {sort: {created_at: :asc}}).inspect
        # puts Patient.search({last_name: {value: "Las*", starts_with: true}}, {sort: {created_at: :asc}}).inspect
      end
    end
  end
end