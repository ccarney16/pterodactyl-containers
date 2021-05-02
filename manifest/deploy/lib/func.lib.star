#! This provides functions that otherwise dont fit with services.

load("@ytt:assert", "assert")
load("@ytt:data", "data")

load("@ytt:md5", "md5")

# Checks if the panel and or daemon are enabled. If neither are enabled, enable defaults
def service_check():
  if (data.values.panel.enabled != True) and (data.values.daemon.enabled != True):
    assert.fail("Panel and or daemon must be enabled for deployment.")
  end
end

# Determines if the cron service is required.
def require_cron():
  if (data.values.panel.enabled == True):
    return True
  end
  if (data.values.letsencrypt.enabled == True ):
    return True
  end
  return False
end

# Determines the SSL certificate and key
def ssl_certificates():

end
