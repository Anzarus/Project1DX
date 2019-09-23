/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

({
    checkIfProdHasFile: function (cmp) {
        const recordId = cmp.get("v.recordId");

        const requestCmp = cmp.find("requestCmp");
        const toastCmp = cmp.find("toastCmp");

        requestCmp.requestPromise(
            "isProdHasFile",
            {recordId: recordId}
        ).then(function (result) {
            if (result) {
                cmp.set("v.hasFile", result);
            }
        }).catch(function (errors) {
            let errorMessage = 'Unknown error';
            if (errors && Array.isArray(errors) && errors.length > 0) {
                errorMessage = errors[0].message;
            }
            toastCmp.showToast($A.get("$Label.c.err"), errorMessage, 'error');
        });
    },

    getDownloadLinkForFile: function (cmp) {
        const recordId = cmp.get("v.recordId");

        const requestCmp = cmp.find("requestCmp");
        const toastCmp = cmp.find("toastCmp");

        requestCmp.requestPromise(
            "getFileForThisRecord",
            {recordId: recordId}
        ).then(function (result) {
            if (result[0] === undefined) {
                toastCmp.showToast($A.get("$Label.c.err"), 'Unknown error', 'error');
            } else {
                for (let i = 0; result[i] !== undefined; i++) {
                    window.open(result[i].toString(), "_blank");
                }
            }
        }).catch(function (errors) {
            let errorMessage = 'Unknown error';
            if (errors && Array.isArray(errors) && errors.length > 0) {
                errorMessage = errors[0].message;
            }
            toastCmp.showToast($A.get("$Label.c.err"), errorMessage, 'error');
        });
    }
});