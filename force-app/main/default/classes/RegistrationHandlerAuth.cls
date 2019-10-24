/**
 * Created by AntonAntoniuk on 24.10.2019.
 */

public with sharing class RegistrationHandlerAuth implements Auth.RegistrationHandler {

    public User createUser(Id portalId, Auth.UserData data) {
        User u = analyzeUser(data);
        handleUser(u.Username == null, u, data);
        return u;
    }

    public void updateUser(Id userId, Id portalId, Auth.UserData data) {
        User u = new User(Id = userId);
        handleUser(false, u, data);
        update(u);
    }

    private void handleUser(Boolean create, User u, Auth.UserData data) {
        if (create) {
            if (canCreateUser(data)) {
                setRequiredUserFieldsOnCreate(u, data);
            }
        }
        setRequiredMutableFields(u, data);
    }

    private void setRequiredMutableFields(User u, Auth.UserData data) {
        u.LastName = data.lastName;
        u.FirstName = data.firstName;
        u.Alias = data.lastName.length() > 5 ? data.lastName.substring(0, 5) : data.lastName;

        String uid = UserInfo.getUserId();
        User currentUser = [
                SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey
                FROM User
                WHERE Id = :uid
        ];
        u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        u.LocaleSidKey = currentUser.LocaleSidKey;
        u.EmailEncodingKey = currentUser.EmailEncodingKey;
        u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
    }

    private void setRequiredUserFieldsOnCreate(User u, Auth.UserData data) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];

        u.ProfileId = p.Id;
        u.Username = data.email + getRandomNumberValue(5);
        u.CommunityNickname = 'User' + getRandomNumberValue(20);
        u.Email = data.email;
    }

    private User analyzeUser(Auth.UserData data) {
        List<User> users = [
                SELECT Id, Username, Email
                FROM User
                WHERE IsActive = TRUE AND (Username = :data.username OR Email = :data.email)
        ];
        User u = new User();
        if (!users.isEmpty()) {
            u = users[0];
        }
        return u;
    }

    private Boolean canCreateUser(Auth.UserData data) {
        if (String.isEmpty(data.email)
                || String.isEmpty(data.lastName)) {
            throw new RegistrationHandlerAuthException('User cannot be created!'
                    + 'Email:' + data.email
                    + 'Last Name:' + data.lastName);
        }
        return true;
    }

    private String getRandomNumberValue(Integer length) {
        String result = '';
        for (Integer i = 0; i < length; i++) {
            result += Integer.valueOf(9 * Math.random());
        }
        return result;
    }

    private class RegistrationHandlerAuthException extends Exception {
    }
}