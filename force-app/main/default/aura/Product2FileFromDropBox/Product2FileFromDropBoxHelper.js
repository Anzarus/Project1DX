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
                cmp.set("v.disabled");
            }
        }).catch(function (errors) {
            let errorMessage = 'Unknown error';
            if(errors && Array.isArray(errors) && errors.length > 0){
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
            if (result.toString().startsWith("Error")) {
                toastCmp.showToast("Error", result, "error");
            } else {
                window.open(result.toString(), "_self");
            }
        }).catch(function (errors) {
            let errorMessage = 'Unknown error';
            if(errors && Array.isArray(errors) && errors.length > 0){
                errorMessage = errors[0].message;
            }
            toastCmp.showToast($A.get("$Label.c.err"), errorMessage, 'error');
        });
    }
});