$headers = @{}
$baseUrl = ""
$userAgent = "OktaAPIWindowsPowerShell/0.1" # "PowerShell/$($PSVersionTable.PSVersion)"

# Call Connect-Okta before calling Okta API functions.
function Connect-Okta($token, $baseUrl) {
    $script:headers = @{"Authorization" = "SSWS $token"; "Accept" = "application/json"; "Content-Type" = "application/json"}
    $script:baseUrl = $baseUrl
}

# Apps - https://developer.okta.com/docs/api/resources/apps

function New-OktaApp($app, $activate = $true) {
    Invoke-Method POST "/api/v1/apps?activate=$activate" $app
}

function Get-OktaApp($appid) {
    Invoke-Method GET "/api/v1/apps/$appid"
}

function Get-OktaApps($filter, $limit = 20, $expand, $url = "/api/v1/apps?filter=$filter&limit=$limit&expand=$expand") {
    Invoke-PagedMethod $url
}

function Add-OktaAppUser($appid, $appuser) {
    Invoke-Method POST "/api/v1/apps/$appid/users" $appuser
}

function Get-OktaAppUser($appid, $userid) {
    Invoke-Method GET "/api/v1/apps/$appid/users/$userid"
}

function Get-OktaAppUsers($appid, $limit = 20, $url = "/api/v1/apps/$appid/users?limit=$limit") {
    Invoke-PagedMethod $url
}

function Set-OktaAppUser($appid, $userid, $appuser) {
    Invoke-Method POST "/api/v1/apps/$appid/users/$userid" $appuser
}

function Remove-OktaAppUser($appid, $userid) {
    $noContent = Invoke-Method DELETE "/api/v1/apps/$appid/users/$userid"
}

function Add-OktaAppGroup($appid, $groupid, $group) {
    Invoke-Method PUT "/api/v1/apps/$appid/groups/$groupid" $group
}

function Get-OktaAppGroups($appid, $limit = 20, $url = "/api/v1/apps/$appid/groups?limit=$limit") {
    Invoke-PagedMethod $url
}

function Remove-OktaAppGroup($appid, $groupid) {
    $noContent = Invoke-Method DELETE "/api/v1/apps/$appid/groups/$groupid"
}

# Events - https://developer.okta.com/docs/api/resources/events

function Get-OktaEvents($startDate, $filter, $limit = 1000, $url = "/api/v1/events?startDate=$startDate&filter=$filter&limit=$limit", $paged = $false) {
    if ($paged) {
        Invoke-PagedMethod $url
    } else {
        Invoke-Method GET $url
    }
}

# Factors (MFA) - https://developer.okta.com/docs/api/resources/factors

function Get-OktaFactor($userid, $factorid) {
    Invoke-Method GET "/api/v1/users/$userid/factors/$factorid"
}

function Get-OktaFactors($userid) {
    Invoke-Method GET "/api/v1/users/$userid/factors"
}

function Set-OktaFactor($userid, $factor) {
    Invoke-Method POST "/api/v1/users/$userid/factors" $factor
}

# Groups - https://developer.okta.com/docs/api/resources/groups

function New-OktaGroup($group) {
    Invoke-Method POST "/api/v1/groups" $group
}

function Get-OktaGroup($id) {
    Invoke-Method GET "/api/v1/groups/$id"
}

function Get-OktaGroups($q, $filter, $limit = 200, $url = "/api/v1/groups?q=$q&filter=$filter&limit=$limit", $paged = $false) {
    if ($paged) {
        Invoke-PagedMethod $url
    } else {
        Invoke-Method GET $url
    }
}

function Get-OktaGroupMember($id, $limit = 200, $url = "/api/v1/groups/$id/users?limit=$limit", $paged = $false) {
    if ($paged) {
        Invoke-PagedMethod $url
    } else {
        Invoke-Method GET $url
    }
}

function Add-OktaGroupMember($groupid, $userid) {
    $noContent = Invoke-Method PUT "/api/v1/groups/$groupid/users/$userid"
}

function Remove-OktaGroupMember($groupid, $userid) {
    $noContent = Invoke-Method DELETE "/api/v1/groups/$groupid/users/$userid"
}

# Logs - https://developer.okta.com/docs/api/resources/system_log

function Get-OktaLogs($since, $until, $filter, $q, $sortOrder = "ASCENDING", $limit = 100, $url = "/api/v1/logs?since=$since&until=$until&filter=$filter&q=$q&sortOrder=$sortOrder&limit=$limit", $convert = $true) {
    Invoke-PagedMethod $url $convert
}

# Roles - https://developer.okta.com/docs/api/resources/roles

function Get-OktaRoles($id) {
    Invoke-Method GET "/api/v1/users/$id/roles"
}

# Users - https://developer.okta.com/docs/api/resources/users

function New-OktaUser($user, $activate = $true) {
    Invoke-Method POST "/api/v1/users?activate=$activate" $user
}

function Get-OktaUser($id) {
    Invoke-Method GET "/api/v1/users/$id"
}

function Get-OktaUsers($q, $filter, $limit = 200, $url = "/api/v1/users?q=$q&filter=$filter&limit=$limit&search=$search", $search) {
    Invoke-PagedMethod $url
}

function Set-OktaUser($id, $user) {
# Only the profile properties specified in the request will be modified when using the POST method.
    Invoke-Method POST "/api/v1/users/$id" $user
}

function Get-OktaUserGroups($id) {
    Invoke-Method GET "/api/v1/users/$id/groups"
}

function Enable-OktaUser($id, $sendEmail = $true) {
    Invoke-Method POST "/api/v1/users/$id/lifecycle/activate?sendEmail=$sendEmail"
}

function Disable-OktaUser($id) {
    $noContent = Invoke-Method POST "/api/v1/users/$id/lifecycle/deactivate"
}

function Set-OktaUserResetPassword($id, $sendEmail = $true) {
    Invoke-Method POST "/api/v1/users/$id/lifecycle/reset_password?sendEmail=$sendEmail"
}

function Set-OktaUserExpirePassword($id) {
    Invoke-Method POST "/api/v1/users/$id/lifecycle/expire_password"
}

function Remove-OktaUser($id) {
    $noContent = Invoke-Method DELETE "/api/v1/users/$id"
}

# Zones - https://developer.okta.com/docs/api/resources/zones

function Get-OktaZone($id) {
    Invoke-Method GET "/api/v1/zones/$id"
}

function Get-OktaZones($filter, $limit = 20, $url = "/api/v1/zones?filter=$filter&limit=$limit") {
    Invoke-PagedMethod $url
}

# Core functions

function Invoke-Method($method, $path, $body) {
    $url = $baseUrl + $path
    $jsonBody = $body | ConvertTo-Json -compress -Depth 100 # max depth is 100. pipe works better than InputObject
    Invoke-RestMethod $url -Method $method -Headers $headers -Body $jsonBody -UserAgent $userAgent
}

function Invoke-PagedMethod($url, $convert = $true) {
    if ($url -notMatch '^http') {$url = $baseUrl + $url}
    $response = Invoke-WebRequest $url -Method GET -Headers $headers -UserAgent $userAgent
    $links = @{}
    if ($response.Headers.Link) { # Some searches (eg List Users with Search) do not support pagination.
        foreach ($header in $response.Headers.Link.split(",")) {
            if ($header -match '<(.*)>; rel="(.*)"') {
                $links[$matches[2]] = $matches[1]
            }
        }
    }
    $objects = $null
    if ($convert) {
        $objects = ConvertFrom-Json $response.content
    }
    @{objects = $objects
      nextUrl = $links.next
      response = $response
      limitLimit = [int][string]$response.Headers.'X-Rate-Limit-Limit'
      limitRemaining = [int][string]$response.Headers.'X-Rate-Limit-Remaining' # how many calls are remaining
      limitReset = [int][string]$response.Headers.'X-Rate-Limit-Reset' # when limit will reset, see also [DateTimeOffset]::FromUnixTimeSeconds(limitReset)
    }
}

function Get-Error($_) {
    $responseStream = $_.Exception.Response.GetResponseStream()
    $responseReader = New-Object System.IO.StreamReader($responseStream)
    $responseContent = $responseReader.ReadToEnd()
    ConvertFrom-Json $responseContent
}
