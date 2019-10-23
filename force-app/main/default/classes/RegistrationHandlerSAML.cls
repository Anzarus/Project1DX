/**
 * Created by AntonAntoniuk on 23.10.2019.
 */

global with sharing class RegistrationHandlerSAML implements Auth.SamlJitHandler {

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = analyzeUser(federationIdentifier, attributes);
        handleJit(u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, Username FROM User WHERE Id = :userId];
        handleJit(u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes);
    }

    private User analyzeUser(String federationIdentifier, Map<String, String> attributes) {
        User u = null;
        if (attributes.containsKey('User.FederationIdentifier')) {
            u = [
                    SELECT Id, Username
                    FROM User
                    WHERE /*FederationIdentifier = :attributes.get('User.FederationIdentifier')
                    AND */(Username = :attributes.get('User.Username') OR Email = :attributes.get('User.Email'))
                    LIMIT 1
            ];
        } else {
            u = [
                    SELECT Id, Username
                    FROM User
                    WHERE /*FederationIdentifier = :federationIdentifier
                    AND */(Username = :attributes.get('User.Username') OR Email = :attributes.get('User.Email'))
                    LIMIT 1
            ];
        }
        if (u == null) {
            u = new User();
        }
        return u;
    }

    private void handleJit(User u, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes) {
        if (communityId == null && portalId == null) {
            handleUser(u.Username == null, u, samlSsoProviderId, federationIdentifier, attributes);
        }
    }

    private void handleUser(Boolean create, User u, Id samlSsoProviderId,
            String federationIdentifier, Map<String, String> attributes) {
        if (create) {
            if (attributes.containsKey('User.Username')) {
                u.Username = attributes.get('User.Username');
            } else {
                throw new RegistrationHandlerSAMLException('Username has not been defined!');
            }
            if (attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
        }
        if (attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if (attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        } else {
            throw new RegistrationHandlerSAMLException('Email has not been defined!');
        }
        if (attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        if (attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        } else {
            throw new RegistrationHandlerSAMLException('Last Name has not been defined!');
        }
        if (attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        } else if (create) {
            String alias = '';
            if (u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if (alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
        if (attributes.containsKey('User.Title')) {
            u.Title = attributes.get('User.Title');
        }
        if (attributes.containsKey('User.CompanyName')) {
            u.CompanyName = attributes.get('User.CompanyName');
        }
        if (attributes.containsKey('User.AboutMe')) {
            u.AboutMe = attributes.get('User.AboutMe');
        }
        if (attributes.containsKey('User.Street')) {
            u.Street = attributes.get('User.Street');
        }
        if (attributes.containsKey('User.State')) {
            u.State = attributes.get('User.State');
        }
        if (attributes.containsKey('User.City')) {
            u.City = attributes.get('User.City');
        }
        if (attributes.containsKey('User.Zip')) {
            u.PostalCode = attributes.get('User.Zip');
        }
        if (attributes.containsKey('User.Country')) {
            u.Country = attributes.get('User.Country');
        }
        if (attributes.containsKey('User.CallCenter')) {
            u.CallCenterId = attributes.get('User.CallCenter');
        }
        if (attributes.containsKey('User.Manager')) {
            u.ManagerId = attributes.get('User.Manager');
        }
        if (attributes.containsKey('User.MobilePhone')) {
            u.MobilePhone = attributes.get('User.MobilePhone');
        }
        if (attributes.containsKey('User.DelegatedApproverId')) {
            u.DelegatedApproverId = attributes.get('User.DelegatedApproverId');
        }
        if (attributes.containsKey('User.Department')) {
            u.Department = attributes.get('User.Department');
        }
        if (attributes.containsKey('User.Division')) {
            u.Division = attributes.get('User.Division');
        }
        if (attributes.containsKey('User.EmployeeNumber')) {
            u.EmployeeNumber = attributes.get('User.EmployeeNumber');
        }
        if (attributes.containsKey('User.Extension')) {
            u.Extension = attributes.get('User.Extension');
        }
        if (attributes.containsKey('User.Fax')) {
            u.Fax = attributes.get('User.Fax');
        }
        if (attributes.containsKey('User.CommunityNickname')) {
            u.CommunityNickname = attributes.get('User.CommunityNickname');
        } else {
            throw new RegistrationHandlerSAMLException('Nickname has not been defined!');
        }
        if (attributes.containsKey('User.ReceivesAdminInfoEmails')) {
            String ReceivesAdminInfoEmailsVal = attributes.get('User.ReceivesAdminInfoEmails');
            u.ReceivesAdminInfoEmails = '1'.equals(ReceivesAdminInfoEmailsVal) || Boolean.valueOf(ReceivesAdminInfoEmailsVal);
        }
        if (attributes.containsKey('User.ReceivesInfoEmails')) {
            String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
            u.ReceivesInfoEmails = '1'.equals(ReceivesInfoEmailsVal) || Boolean.valueOf(ReceivesInfoEmailsVal);
        }
        String uid = UserInfo.getUserId();
        User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id = :uid];
        if (attributes.containsKey('User.LocaleSidKey')) {
            u.LocaleSidKey = attributes.get('User.LocaleSidKey');
        } else if (create) {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        if (attributes.containsKey('User.LanguageLocaleKey')) {
            u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
        } else if (create) {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        if (attributes.containsKey('User.TimeZoneSidKey')) {
            u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
        } else if (create) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        if (attributes.containsKey('User.EmailEncodingKey')) {
            u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
        } else if (create) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }
        if (attributes.containsKey('User.IsActive')) {
            String IsActiveVal = attributes.get('User.IsActive');
            u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
        }
        if (attributes.containsKey('User.ForecastEnabled')) {
            String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
            u.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
        }
        if (attributes.containsKey('User.ProfileId')) {
            String profileId = attributes.get('User.ProfileId');
            Profile p = [SELECT Id FROM Profile  WHERE Name = 'Chatter Free User' LIMIT 1];
            u.ProfileId = p.Id;
        }
        if (attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r = [SELECT Id FROM UserRole WHERE Id = :userRole];
            u.UserRoleId = r.Id;
        }
        if (!create) {
            update u;
        }
    }

    private class RegistrationHandlerSAMLException extends Exception {
    }
}