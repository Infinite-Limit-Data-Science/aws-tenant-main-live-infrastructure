# Executive Summary

## IAM Identity Center (Configured outside IaC)

As of January 4 2024, there are currently limited operations that we can perform using Terraform. Unfortunately, if you want to set up the AWS SSO ( IAM Identity Center ), you must start the process manually using the ClickOps (aka AWS Console) approach. To do so, you will need to follow the steps below:

- Login to your root admin account
- Select primary region
- Go to IAM Identity Center (successor to AWS Single Sign-On)
- Click on the Enable button

Note IAM Identity Center requires AWS Organizations. It will automatically setup an AWS Organization for you. It will automatically create a Root for you. **The "Organization Root" refers to the top-level entity that represents an organization within the AWS Management Console**. It serves as a central hub for managing and organizing all of the resources within an organization's account hierarchy.

If you only have one account (which is probably how you will start), it will make that single account the "Management Account".

- Service Control Policies (SCPs) 
IAM Identity Center enables you to manage workforce user access to multiple AWS accounts and applications. Use service control policies (SCPs) to prevent instances of IAM Identity Center from being created, or isolate the member accounts that are allowed to create account instances. 

- CloudTrail (Monitor activities in your instances of IAM Identity Center)
With AWS CloudTrail, you can monitor and audit activity in your organization instance and account instances of IAM Identity Center.

## IAM Identity Center Identity Source "Identity Center Directory" (Configured outside IaC)

The Identity Source in IAM Identity Center (formerly known as Okta Identity Cloud) is a feature that allows you to manage and authenticate users from various sources. By default, the Source is set to the "Identity Center Directory". The "Identity Center Directory" refers to the central repository where all user identities are stored and managed. The Identity Center Directory acts as a hub for storing, organizing, and securing user information, including usernames, passwords, attributes, roles, and permissions. **Note when you choose "Identity Center Directory", users sign in through the AWS Access Portal**. Instead of "Identity Center Directory", you can manage all users and groups in AWS Managed Microsoft AD. In this case, users also sign in through the AWS Access Portal. You can also use an External Identity Provider. You will manage all users and groups in an external identity provider (IdP). Users sign in to your IdP sign-in page, and are redirected to the AWS access portal. After they sign in to the AWS access portal, they can access their assigned AWS accounts and cloud applications.

## Connecting Azure Active Directory as an Identity Source for AWS Identity Center (configured outside IaC)

**Note when you chose Azure Active Directory, the "Identity Source" must be marked as "External Identity Provider"**. When configuring the "External Identity Provider", you are dealing with "Service Provider MetaData" and "Identity Provider MetaData". **Under "Service Provider MetaData", you download the "AWS SSO SAML MetaData". This is used to create the Federation between the AWS Identity Center and Azure AD Enterprise Application for AWS Identity Center**. So you must download this saml file. In the "Identity Provider MetaData" section of the AWS Identity Source Console, we need to upload the SAML Federation MetaData file to Azure. Go into the Azure Active Directory Console. Visit the Enteprise Applications link. Click on New Application. Select Non-gallery Application. Enter a name, such as "AWS SSO". Click Add. Then under "Manage", go to Single Sign-On. Then select "SAML". Now you are on the configuration page to upload "Upload MetaData file". Browse to the saml file on your computer. And add it. In the Microsoft ActiveDirectory page, this satisfies the Identity (Entity ID). **Now you must grab the federation metadata from the Azure side. So under "SAML Signing Certificate", download the link "Federation MetaData XML". Now return to AWS and under "Identity Provider MetaData", under IdP SAML metadata, upload the saml metadata file from the Azure side. Then you change the identity source from "Identity Center Directory" to "External Identity Provider"**. Notice the Identity Source is now "External Identity Provider". Notice the "Authentication" mechanism is now "SAML 2.0". Under "Provisioning", click on "Enable automatic provisioning". This will give you a "SCIM" endpoint and an "Access Token". This will be shown only once. Now return back to the Azure AD Console. Click on "Provisioning". Set provisioning mode to "Automatic". Past the SCIM endpoint as the Tenant URL. Then grab the "Access Token" from AWS and paste it into the "Secret Token" portion and then "Test Connection". Verify the endpoint access is verified. Inside Azure, click on "Start Provisioning". When you need to create an Enterprise Application in Azure, you need to assign users to the Enterprise Application. So in Azure, you can go to Users and Groups under Manage, select a User or Group and click on "assign" and now you can see in Azure Active Directory, that User or Group is assigned to your AWS SSO Enterprise Application in Azure. Now if you return back to AWS Identity Center Console, and click on Users in AWS Identity Center Console, you will now see the user from Azure AD. Now what can we do with this User or Group? In IAM Identity Center, go into AWS Accounts. Select an account. And there you can assign the User or Group. Note best practice is to assign Groups to Accounts, not Users to Accounts! 

## Users and Groups in IAM Identity Center

Note if you specify "Identity Center Directory" as Identity Source, you should then configure Users and Groups. In IAM Identity Center, both Users and Groups are essential components of user management. However, they serve different purposes and have distinct characteristics. A User in IAM Identity Center represents an individual person within an organization. Each user account contains unique information, such as username, password, first name, last name, email address, phone number, and other attributes. When a new employee joins an organization, a user account is created for them in the Identity Center Directory, which includes their personal details and any necessary access rights and permissions.

**A Group in IAM Identity Center represents a collection of users who share similar characteristics, such as job function, department, or project team. Groups provide a way to organize and manage large numbers of users more efficiently, without having to create and maintain individual user accounts for each one. Instead, group membership allows administrators to assign common access rights and permissions to multiple users at once, simplifying user management tasks and reducing the potential for errors**. While Users represent individual people, Groups allow organizations to manage groups of users as a whole. For example, when creating a new application, an administrator might add all members of a particular group to the application's user base, granting them access to relevant resources and functionality. Similarly, when updating access rights or revoking privileges, changes can be made to the group membership rather than modifying individual user accounts.

Note Users created in IAM Identity Center are not the same kind of users you create in the IAM Console. To create an IAM User, you log into a specific account and create the users inside of that account. IAM Identity Center sits outside of your accounts, you if will, at a higher level. When you create a user in IAM Identity Center, you create a User that can be used across multiple accounts. Note Users and Groups can be provisioned as IaC with Terraform for Users and Groups.

## Permission Sets

Permission sets in IAM Identity Center are a way to define a set of permissions that can be attached to an IAM user or group. A permission set contains a combination of policies, which are documents that describe the operations that a user or group is allowed to perform on a particular resource. Permission sets allow you to granularly control access to resources in IAM Identity Center by attaching different sets of permissions to different users or groups.

There are two types of permission sets in IAM Identity Center: managed permission sets and custom permission sets. Managed permission sets are predefined by AWS and can be used to grant common permissions, such as access to AWS services or resources. Custom permission sets, on the other hand, are created by you and can contain any combination of policies that you define.

## Multi-account Permissions

In the IAM Identity Center Console, more ClickOps will be required for the tenant-administrator. Under AWS Accounts, you must specify what accounts you want to associate the sso user (e.g. tenant-administrator) with. In the case of tenant-administrator, you will want to associate it will all accounts. Once you specify the AWS accounts to associate with the tenant-administrator, then you specify the Permission Set to associate with the given account. You will want to use the Permission Set AdministratorAccess for the tenant-administrator. Once this is done, you can verify the ClickOps worked by accessing the AWS Portal with the tenant-administrator. **The AWS Access Portal URL is specific to IAM Identity Center, and it is a different URL from the traditional console where you sign-in as IAM user.**

## Accessing SSO User with Credentials

**When deploying IaC, you will need access credentials, typically stored in ~/.aws/credentials file in your $HOME directory of your OS. Remember The SSO User only has temporary credentials. Therefore to utilize these temporary credentials, you must specify aws_access_key_id, aws_secret_access_key and aws_session_token attributes in your ~/.aws/credentials file or AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN as environment variables in your OS. This will give you short-term permissions to provision IaC via the AWS Identity Center User/Group. To find the credential information, when you log into through the AWS Access Portal URL, you select the account and then you click the link "Command line or programmatic access". This will provide your secret credentials.** It will look something like this:

```code
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."


[975474249947_AdministratorAccess]
aws_access_key_id=...
aws_secret_access_key=...
aws_session_token=...
```

