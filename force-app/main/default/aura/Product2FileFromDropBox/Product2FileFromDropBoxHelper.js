/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

({
    requestDownloadLinkForFile: function (cmp) {
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
        });
    }
});