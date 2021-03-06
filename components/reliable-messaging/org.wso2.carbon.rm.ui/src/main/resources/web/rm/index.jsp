<!--
/*
* Copyright (c) 2008, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
-->
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" prefix="carbon" %>
<%@ page import="org.apache.axis2.context.ConfigurationContext" %>
<%@ page import="org.apache.axis2.client.Options" %>
<%@ page import="org.apache.axis2.client.ServiceClient" %>
<%@ page import="org.wso2.carbon.CarbonConstants"%>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.rm.stub.service.RMAdminServiceStub"%>
<%@ page import="org.wso2.carbon.rm.stub.service.xsd.RMParameterBean"%>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIMessage" %>


<jsp:include page="../dialog/display_messages.jsp"/>

<%
    String serviceName = request.getParameter("serviceName");

    if (request.getParameter("backURL") != null) {
        session.setAttribute("backURL", request.getParameter("backURL"));
    }

    ConfigurationContext configContext = (ConfigurationContext) config.getServletContext()
            .getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);

    //Server URL which is defined in the server.xml
    String serverURL = CarbonUIUtil.getServerURL(config.getServletContext(),
            session) + "RMAdminService.RMAdminServiceHttpsSoap12Endpoint";

    RMAdminServiceStub stub = new RMAdminServiceStub(configContext, serverURL);

    String cookie = (String)session.getAttribute(org.wso2.carbon.utils.ServerConstants.ADMIN_SERVICE_COOKIE);
    ServiceClient client = stub._getServiceClient();
    Options option = client.getOptions();
    option.setManageSession(true);
    option.setProperty(org.apache.axis2.transport.http.HTTPConstants.COOKIE_STRING, cookie);

    RMParameterBean rmParameterBean = null;
    try {
        rmParameterBean = stub.getParameters(serviceName);
    } catch (Exception e) {
        CarbonUIMessage.sendCarbonUIMessage(e.getMessage(), CarbonUIMessage.ERROR, request, e);
        %>
        <script type="text/javascript">
            location.href = "../admin/error.jsp";
        </script>
        <%
        return;
    }

    long inactivityTimeoutInterval = rmParameterBean.getInactivityTimeoutInterval();

    long sequenceRemovalTimeoutInterval = rmParameterBean.getSequenceRemovalTimeoutInterval();

    long acknowledgementInterval = rmParameterBean.getAcknowledgementInterval();

    long retransmissionInterval = rmParameterBean.getRetransmissionInterval();

    boolean exponentialBackoff = rmParameterBean.getExponentialBackoff();

    int maximumRetransmissionCount = rmParameterBean.getMaximumRetransmissionCount();

    boolean isRMEngaged = false;
    try {
        isRMEngaged = stub.isRMEnabled(serviceName);
    } catch (Exception e) {
        CarbonUIMessage.sendCarbonUIMessage(e.getMessage(), CarbonUIMessage.ERROR, request, e);
        %>
        <script type="text/javascript">
            location.href = "../admin/error.jsp";
        </script>
        <%
        return;
    }

    String style = "display: none;";
    if(isRMEngaged){
        style = "display: inline;";
    }
%>

<fmt:bundle basename="org.wso2.carbon.rm.ui.i18n.Resources">
<carbon:breadcrumb label="enable.rm"
                   resourceBundle="org.wso2.carbon.rm.ui.i18n.Resources"
                   topPage="false" request="<%=request%>"/>

<script type="text/javascript">
    function showHide(obj) {

        var selectedIndex = obj.selectedIndex;

        if (selectedIndex == 1) {//If yes
            document.getElementById('tableWithDetails').style.display = "";
        } else {
            CARBON.showConfirmationDialog("<fmt:message key="index.confirm"/>", function() {
                document.getElementById('tableWithDetails').style.display = "none";
                document.rmForm.action = "update.jsp?serviceName=<%= serviceName%>";
                document.rmForm.submit();
            }, function() {
                document.getElementById('tableWithDetails').style.display = "";
                obj.selectedIndex = 1;
            });
        }
    }


   function clearAll() {
        document.rmForm.inactivityTimeoutMeasure.value = "";
        document.rmForm.inactivityTimeoutInterval.value = "";

        document.rmForm.sequenceRemovalTimeoutMeasure.value = "";
        document.rmForm.sequenceRemovalTimeoutInterval.value = "";

        document.rmForm.acknowledgementInterval.value = "";
        document.rmForm.retransmissionInterval.value = "";
        document.rmForm.exponentialBackoff.value = "";
        document.rmForm.maximumRetransmissionCount.value = "";

    }

   function resetValues() {
	       document.rmForm.inactivityTimeoutMeasure.value = "<fmt:message key="common.seconds"/>";
	       document.rmForm.inactivityTimeoutInterval.value = "<%=inactivityTimeoutInterval%>";

	       document.rmForm.sequenceRemovalTimeoutMeasure.value = "<fmt:message key="common.seconds"/>";
	       document.rmForm.sequenceRemovalTimeoutInterval.value =  "<%= sequenceRemovalTimeoutInterval%>";

           document.rmForm.acknowledgementInterval.value = "<%= acknowledgementInterval%>";
	       document.rmForm.retransmissionInterval.value = "<%= retransmissionInterval%>";
	       document.rmForm.exponentialBackoff.value = "<%= exponentialBackoff%>";
	       document.rmForm.maximumRetransmissionCount.value = "<%= maximumRetransmissionCount%>";
   }

   function submitForm(){

       var regx = RegExp("\\d+");
       if (!document.rmForm.inactivityTimeoutInterval.value.match(regx)) {
           CARBON.showWarningDialog("<fmt:message key="common.error.message.inactivityTimeoutInterval"/>");
           return;
       }

       if (!document.rmForm.sequenceRemovalTimeoutInterval.value.match(regx)) {
           CARBON.showWarningDialog("<fmt:message key="common.error.message.sequenceRemovalTimeoutInterval"/>");
           return;
       }

       if (!document.rmForm.acknowledgementInterval.value.match(regx)) {
           CARBON.showWarningDialog("<fmt:message key="common.error.message.acknowledgementInterval"/>");
           return;
       }

       if (!document.rmForm.retransmissionInterval.value.match(regx)) {
           CARBON.showWarningDialog("<fmt:message key="common.error.message.retransmissionInterval"/>");
           return;
       }

       if (!document.rmForm.maximumRetransmissionCount.value.match(regx)) {
           CARBON.showWarningDialog("<fmt:message key="common.error.message.maximumRetransmissionCount"/>");
           return;
       }

       document.rmForm.action = "update.jsp?serviceName=<%= serviceName%>";
       document.rmForm.submit();
   }

   function setDefaults() {
       document.rmForm.inactivityTimeoutMeasure.value = "<fmt:message key="common.seconds"/>";
       document.rmForm.inactivityTimeoutInterval.value = "60";

       document.rmForm.sequenceRemovalTimeoutMeasure.value = "<fmt:message key="common.seconds"/>";
       document.rmForm.sequenceRemovalTimeoutInterval.value = "600";

       document.rmForm.acknowledgementInterval.value = "3000";
       document.rmForm.retransmissionInterval.value = "6000";
       document.rmForm.exponentialBackoff.value = "true";
       document.rmForm.maximumRetransmissionCount.value = "10";
   }

   function goBack() {
       location.href = "<%= (String) session.getAttribute("backURL")%>";
   }

</script>


<carbon:breadcrumb 
		label="reliable.messaging"
		resourceBundle="org.wso2.carbon.rm.ui.i18n.Resources"
		topPage="false" 
		request="<%=request%>" />
<div id="middle">
<h2><fmt:message key="index.enable.rm.for"/>  <%=serviceName%></h2>

<div id="workArea">
<form id="form3" name="rmForm" method="post" >
<input name="serviceName" type="hidden" value="<%=serviceName%>"/>

        <table>
            <tr>
                <td>
                    <% if (isRMEngaged){ %><fmt:message key="common.rmenabled"/><% } %>
                    <% if (!isRMEngaged){ %><fmt:message key="common.rmdisabled"/><% } %>
                </td>
            </tr>
            <tr>
                <td>
                   <fmt:message key="index.enable.rm"/>
                </td>
                <td>
                    <select name="isRMEngaged" onchange="showHide(this)">
                        <option value="false" <% if (!isRMEngaged) { %> selected <% } %> ><fmt:message key="index.no"/></option>
                        <option value="true" <% if (isRMEngaged) { %> selected <% } %> ><fmt:message key="index.yes"/></option>
                    </select>
                </td>
            </tr>
        </table>
        <p>&nbsp;</p>

<table border="0" id="tableWithDetails" class="styledLeft"style="<%= style%>">
      <thead>
      <tr>
          <th><fmt:message key="common.rm.sequence.configuration"/></th>
      </tr>
      </thead><tbody>
    <tr>
        <td class="formRow">
        <table class="normal">
            <tr>
        <td><fmt:message key="common.inactivity.timeout.interval"/></td>
        <td><input name="inactivityTimeoutInterval" type="text" value="<%=inactivityTimeoutInterval%>"/></td>
    </tr>
    <tr>
        <td><fmt:message key="common.inactivity.timeout.measure"/></td>
        <td>
            <label>
                <select name="inactivityTimeoutMeasure">
                    <option value="seconds" selected ><fmt:message key="common.seconds"/></option>
                    <option value="minutes" ><fmt:message key="common.minutes"/></option>
                    <option value="hours" ><fmt:message key="common.hours"/></option>
                    <option value="days" ><fmt:message key="common.days"/></option>
                </select>
            </label>
        </td>
    </tr>
    <tr>
        <td><fmt:message key="common.sequence.removal.timeout.interval"/></td>
        <td><input name="sequenceRemovalTimeoutInterval" type="text" value="<%=sequenceRemovalTimeoutInterval%>"/></td>
    </tr>
    <tr>
        <td><fmt:message key="common.sequence.removal.timeout.measure"/></td>
        <td>
            <label>
                <select name="sequenceRemovalTimeoutMeasure">
                    <option value="seconds" selected ><fmt:message key="common.seconds"/></option>
                    <option value="minutes" ><fmt:message key="common.minutes"/></option>
                    <option value="hours" ><fmt:message key="common.hours"/></option>
                    <option value="days" ><fmt:message key="common.days"/></option>
                </select>
            </label>
        </td>
    </tr>
    <tr>
        <td><fmt:message key="common.acknowledgment.interval"/></td>
        <td><input name="acknowledgementInterval" type="text" value="<%=acknowledgementInterval%>"/></td>
    </tr>
    <tr>
        <td><fmt:message key="common.retransmission.interval"/></td>
        <td><input name="retransmissionInterval" type="text" value="<%=retransmissionInterval%>"/></td>
    </tr>
    <tr>
        <td><fmt:message key="common.exponentialbackoff"/></td>
        <td>
            <label>
                <select name="exponentialBackoff">
                    <option value="true" <% if (exponentialBackoff) { %> selected <% } %> ><fmt:message key="common.true"/></option>
                    <option value="false" <% if (!exponentialBackoff) { %> selected <% } %> ><fmt:message key="common.false"/></option>
                </select>
            </label>
        </td>
    </tr>
    <tr>
        <td><fmt:message key="common.maximum.retransmission.time"/></td>
        <td><input name="maximumRetransmissionCount" type="text" value="<%=maximumRetransmissionCount%>"/></td>
    </tr></table>
    </td>
    </tr>
    <tr>
        <td class="buttonRow">
            <input type="button" Id="Done" name="Submit" value="<fmt:message key="common.done"/>" onclick="submitForm();" class="button"/>
            <input type="button" Id="ResetButton" name="ResetButton" value="<fmt:message key="common.reset"/>" onclick="resetValues();" class="button"/>
            <input type="button" Id="Default" name="Default" value="<fmt:message key="common.default"/>" onclick="setDefaults();" class="button"/>
            <input type="button" Id="Clear" name="Clear" value="<fmt:message key="common.clear"/>" onclick="clearAll();" class="button"/>
            <input type="button" Id="cancelButton" name="Cancel" value="<fmt:message key="common.cancel"/>" class="button" onClick="goBack();return false;"/>
        </td>
    </tr></tbody>
</table>

</form>
</div>
</div>
</fmt:bundle>
</html>
