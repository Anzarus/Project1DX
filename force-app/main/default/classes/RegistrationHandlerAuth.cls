/**
 * Created by AntonAntoniuk on 24.10.2019.
 */

public with sharing class RegistrationHandlerAuth implements Auth.RegistrationHandler {

    public User createUser(Id portalId, Auth.UserData data) {
        User u = findUser(data);
        if (u == null) {
            throw new RegistrationHandlerAuthException('This User can not be found!');
        }
        return u;
    }

    public void updateUser(Id userId, Id portalId, Auth.UserData data) {
        User u = checkUser(userId, data);
        if (u == null) {
            throw new RegistrationHandlerAuthException('This User can not be found!');
        }
    }

    private User findUser(Auth.UserData data) {
        String federationId = getFederationId(data);

        List<User> users = [
                SELECT Id
                FROM User
                WHERE IsActive = TRUE
                AND FederationIdentifier = :federationId
        ];
        User u;
        if (!users.isEmpty()) {
            u = users[0];
        }
        return u;
    }

    @TestVisible
    private User checkUser(Id userId, Auth.UserData data) {
        String federationId = getFederationId(data);

        List<User> users = [
                SELECT Id
                FROM User
                WHERE IsActive = TRUE
                AND Id = :userId AND FederationIdentifier = :federationId
        ];
        User u;
        if (!users.isEmpty()) {
            u = users[0];
        }
        return u;
    }

    private String getFederationId(Auth.UserData data) {
        String federationId = '';
        if (data.provider == 'Google') {
            federationId += 'google-oauth2|';
        }
        federationId += data.identifier;
        return federationId;
    }

    @TestVisible
    private class RegistrationHandlerAuthException extends Exception {
    }
}
/*


portalId++null
++data++UserData%3A%5B
attributeMap%3D%7B
identifier%3D112533033905571486109%2C+
provider%3DGoogle%2C+*/
