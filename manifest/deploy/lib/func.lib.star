#! This provides functions that otherwise dont fit with services.

load("@ytt:assert", "assert")
load("@ytt:data", "data")

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
