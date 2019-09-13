/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

({
    doInit: function (cmp, event, helper) {
        helper.checkIfProdHasFile(cmp);
    },

    handleDownloadClick: function (cmp, event, helper) {
        helper.getDownloadLinkForFile(cmp);
    }
});