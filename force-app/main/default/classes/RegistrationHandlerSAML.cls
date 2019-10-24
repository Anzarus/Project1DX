/**
 * Created by AntonAntoniuk on 23.10.2019.
 */

public with sharing class RegistrationHandlerSAML implements Auth.SamlJitHandler {

    public User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = analyzeUser(federationIdentifier, attributes);
        handleJit(u, communityId, portalId, federationIdentifier, attributes);
        return u;
    }

    public void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u;
        try {
            u = [SELECT Id, Username FROM User WHERE Id = :userId];
        } catch (Exception e) {
            e.setMessage('updateUser');
        }
        handleJit(u, communityId, portalId, federationIdentifier, attributes);
    }

    private User analyzeUser(String federationIdentifier, Map<String, String> attributes) {
        User u = null;
        if (attributes.containsKey('User.FederationIdentifier')) {
            List<User> users = [
                    SELECT Id, Username, Email
                    FROM User
                    WHERE /*FederationIdentifier = :attributes.get('User.FederationIdentifier') AND*/
                    IsActive = TRUE AND
                    (Username = :attributes.get('User.Username') OR Email = :attributes.get('User.Email'))
            ];
            if (!users.isEmpty()) {
                u = users[0];
            }
        } else {
            List<User> users = [
                    SELECT Id, Username, Email
                    FROM User
                    WHERE /*FederationIdentifier = :federationIdentifier AND*/
                    IsActive = TRUE AND
                    (Username = :attributes.get('User.Username') OR Email = :attributes.get('User.Email'))
            ];
            if (!users.isEmpty()) {
                u = users[0];
            }
        }
        if (u == null) {
            u = new User();
        }
//        throw new RegistrationHandlerSAMLException(''+u);
        return u;
    }

    private void handleJit(User u, Id communityId, Id portalId,
            String federationIdentifier, Map<String, String> attributes) {
        if (communityId == null && portalId == null) {
            handleUser(u.Username == null, u, federationIdentifier, attributes);
        }
    }

    private void handleUser(Boolean create, User u, String federationIdentifier, Map<String, String> attributes) {
        updateAdditionalFields(attributes, u);
        if (create) {
            setRequiredImmutableFieldsOnCreate(attributes, u);
            setRequiredMutableFields(attributes, u, federationIdentifier, true);
        } else {
            setRequiredMutableFields(attributes, u, federationIdentifier, false);
        }
        if (!create) {
            update u;
        }
    }

    private void setRequiredImmutableFieldsOnCreate(Map<String, String> attributes, User u) {
        if (attributes.containsKey('User.Username')) {
            u.Username = attributes.get('User.Username') + getRandomNumberValue(5);
        } else {
            throw new RegistrationHandlerSAMLException('Username has not been defined!');
        }
        if (attributes.containsKey('User.ProfileId')) {
            Profile p;
            try {
                p = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
            } catch (Exception e) {
                e.setMessage('ProfileId');
            }
            u.ProfileId = p.Id;
        }
        if (attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r;
            try {
                r = [SELECT Id FROM UserRole WHERE Id = :userRole];
            } catch (Exception e) {
                e.setMessage('UserRoleId');
            }
            u.UserRoleId = r.Id;
        }
        if (attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        } else {
            throw new RegistrationHandlerSAMLException('Email has not been defined!');
        }
    }

    private void updateAdditionalFields(Map<String, String> attributes, User u) {
        if (attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if (attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
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

        if (attributes.containsKey('User.ReceivesAdminInfoEmails')) {
            String ReceivesAdminInfoEmailsVal = attributes.get('User.ReceivesAdminInfoEmails');
            u.ReceivesAdminInfoEmails = '1'.equals(ReceivesAdminInfoEmailsVal) || Boolean.valueOf(ReceivesAdminInfoEmailsVal);
        }
        if (attributes.containsKey('User.ReceivesInfoEmails')) {
            String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
            u.ReceivesInfoEmails = '1'.equals(ReceivesInfoEmailsVal) || Boolean.valueOf(ReceivesInfoEmailsVal);
        }
        if (attributes.containsKey('User.IsActive')) {
            String IsActiveVal = attributes.get('User.IsActive');
            u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
        }
        if (attributes.containsKey('User.ForecastEnabled')) {
            String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
            u.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
        }
    }

    private void setRequiredMutableFields(Map<String, String> attributes, User u, String federationIdentifier, Boolean create) {
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
        if (attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        } else if (create) {
            String alias = '';
            if (u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            System.debug(alias);
            if (alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
        if (attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        } else {
            throw new RegistrationHandlerSAMLException('Last Name has not been defined!');
        }
        if (attributes.containsKey('User.CommunityNickname')) {
            u.CommunityNickname = attributes.get('User.CommunityNickname');
        } else {
            u.CommunityNickname = 'User' + getRandomNumberValue(20);
            while (![
                    SELECT Id
                    FROM User
                    WHERE CommunityNickname = :u.CommunityNickname
            ].isEmpty()) {//todo remove soql in loop
                u.CommunityNickname = 'User' + getRandomNumberValue(20);
            }
        }
        if (attributes.containsKey('User.FederationIdentifier')) {
            u.FederationIdentifier = attributes.get('User.FederationIdentifier');
        } else {
            u.FederationIdentifier = federationIdentifier;
        }
    }

    private String getRandomNumberValue(Integer length) {
        String result = '';
        for (Integer i = 0; i <length; i++) {
            result += Integer.valueOf(9 * Math.random());
        }
        return result;
    }

    private class RegistrationHandlerSAMLException extends Exception {
    }
}