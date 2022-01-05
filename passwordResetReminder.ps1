###This is where you specify the email information
$emailFrom ="the email you want to send from"
$smtpserver ="the smtp server you want to send from"
###

$users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "Displayname", "msDS-UserPasswordExpiryTimeComputed" |
Select-Object -Property "SamAccountName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

$emailto=""
$expired = New-Object Collections.Generic.List[string]
$date = (Get-Date).AddDays(15)

###populate a list of expired users
foreach ($user in $users)
	{
		if($user.ExpiryDate -lt $date)
		{
			$expired.Add($user.SamAccountName+"@talonlpe.com") 
		}
	}


### send an email to each user that had an expired password
foreach ( $user in $expired)
	{
		$emailto = $user
 

		$MailMessage = @{ 
			To = $emailto 
			From = $emailFrom 
			Subject = "Your Password Will Expire Soon" 
			Body = "This is a notice that your password will expire in less than 15 days. <br> 
			You can update your password by logging into a computer and following these instructions: <br>
				1. Hit CTRL+ALT+DELETE <br>
				2. Select Change Password. <br>
				3. Update your password with at least an <b>8 character password that includes a special character, number, and a capital letter.</b> <br>
			This is required because of our security policies. If you need assistance please contact IT. <br> "
			Smtpserver = $smtpserver 
		}
		Send-MailMessage @MailMessage -BodyAsHtml
	}
