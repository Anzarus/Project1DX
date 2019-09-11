/**
 * Created by AntonAntoniuk on 11.09.2019.
 */

({
    requestLinkForFile: function (cmp) {
        const recordId = cmp.get("v.recordId");

        const requestCmp = cmp.find("requestCmp");

        const request = requestCmp.requestPromise(
            "getFileForThisRecord",
            {recordId: recordId}
        );

        request.then(function (result) {
            window.open(result.toString(), "_blank");
            cmp.set("v.link")
        });
    }
});