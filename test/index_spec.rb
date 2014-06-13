require_relative "spec_helper"

describe TrueVault::Index do
  describe "create!" do
    describe "index does not exists" do
      after { Patient.true_vault_index.delete! }

      it "should create the index" do
        response = Patient.true_vault_index.create!
        response.result.must_equal("success")
        response.transaction_id.wont_be_nil
      end
    end
    describe "index exists" do
      before { Patient.true_vault_index.create! }
      after { Patient.true_vault_index.delete! }

      it "raise error" do
        proc { Patient.true_vault_index.create! }.must_raise TrueVault::Error
      end
    end
  end

  describe "exists?" do
    describe "index does not exist" do
      it { Patient.true_vault_index.exists?.wont_equal true }
    end
    describe "index exists" do
      before { Patient.true_vault_index.create! }
      after { Patient.true_vault_index.delete! }

      it { Patient.true_vault_index.exists?.must_equal true }
    end
  end

  describe "update!" do
    describe "index does not exists" do
      it "raise error" do
        proc { Patient.true_vault_index.update! }.must_raise TrueVault::Error::MissingSchema
      end

    end
    describe "index exists" do
      before { Patient.true_vault_index.create! }
      after { Patient.true_vault_index.delete! }

      it "should update the index" do
        skip("Update is failing on TrueVault(Schema 2fc6bfb1-1447-4070-a925-2eeecf3bd11f updated successfully but failed to reindex)")

        response = Patient.true_vault_index.update!
        response.result.must_equal("success")
        response.transaction_id.wont_be_nil
      end
    end
  end
end
