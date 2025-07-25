<!----- Menu Area Start ------>
<div class="col-md-2 menucontent">
    <a href="#"><h1>Dashboard</h1></a>
    <ul class="nav nav-pills nav-stacked">
        <li role="presentation"><a href="department.jsp">Department</a></li>
        <li role="presentation"><a href="doctor.jsp">Doctors</a></li>
        <li role="presentation"><a href="patients.jsp">Patients</a></li>
        <li role="presentation"><a href="room.jsp">Room</a></li>
        <li role="presentation"><a href="donor.jsp">Blood Donor</a></li>
        <li role="presentation"><a href="billing.jsp">Billing</a></li>
        <li role="presentation"><a href="search.jsp">Search</a></li>
        <% 
            String role = (String) session.getAttribute("role");
            if ("admin".equals(role) || "receptionist".equals(role)) {
        %>
        <li role="presentation"><a href="receptionist.jsp">Receptionist</a></li>
        <% } %>
    </ul>
</div>
<!---- Menu Area Ends -------->