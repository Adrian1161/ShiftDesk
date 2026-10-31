require 'rails_helper'

RSpec.describe "Employee Access Control", type: :system do

    # Create the businesses and employee for testing
    let(:business_1) { create(:business, name: "Business 1") }
    let(:business_2) { create(:business, name: "Business 2") }

end