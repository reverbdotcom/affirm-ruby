def load_fixture(path)
  File.read(File.join(__dir__, "../fixtures", path))
end

def get_request_url(endpoint)
  "https://public_key:secret_key@sandbox.affirm.com/api/v2#{endpoint}"
end
