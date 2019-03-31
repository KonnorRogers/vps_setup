require 'test_helper'

class TestDecryptionConstants < Minitest::Test
  def setup

  end

  def teardown

  end

  def test_create_hash_accurately_creates_hashes_as_expected
    key_array = %i[api api_login api_password]
    hash_name = :heroku
    hash = VpsCli::DecryptionConstants.create_hash(hash_name, key_array)

    heroku_api_string = "[\"heroku\"][\"api\"]"
    heroku_api_password_string = "[\"heroku\"][\"api_password\"]"
    assert_equal hash[:api], heroku_api_string
    assert_equal hash[:api_password], heroku_api_password_string
  end
end

