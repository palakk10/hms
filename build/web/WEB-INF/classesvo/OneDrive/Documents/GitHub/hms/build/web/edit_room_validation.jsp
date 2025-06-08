<%@page import="java.sql.*" %>
<%
    String roomNo = request.getParameter("roomNo");
    String bedNo = request.getParameter("bedNo");
    String oldBedNo = request.getParameter("oldBedNo");
    String status = request.getParameter("status");
    String type = request.getParameter("type");

    try {
        int roomNoInt = Integer.parseInt(roomNo);
        int bedNoInt = Integer.parseInt(bedNo);
        int oldBedNoInt = Integer.parseInt(oldBedNo);

        if (roomNoInt <= 0 || bedNoInt <= 0 || oldBedNoInt <= 0) {
            throw new Exception("Room Number and Bed Number must be positive numbers.");
        }
        if (status == null || status.trim().isEmpty()) {
            throw new Exception("Status is required.");
        }
        if (type == null || type.trim().isEmpty()) {
            throw new Exception("Room Type is required.");
        }

        Connection con = (Connection)application.getAttribute("connection");

        // Check if bed is available
        PreparedStatement checkPs = con.prepareStatement("SELECT status FROM room_info WHERE room_no=? AND bed_no=?");
        checkPs.setInt(1, roomNoInt);
        checkPs.setInt(2, oldBedNoInt);
        ResultSet checkRs = checkPs.executeQuery();
        if (checkRs.next()) {
            String currentStatus = checkRs.getString("status");
            if (!currentStatus.equalsIgnoreCase("available")) {
                throw new Exception("Cannot update bed number for an occupied bed.");
            }
        } else {
            throw new Exception("Room and Bed not found.");
        }
        checkRs.close();
        checkPs.close();

        // Check if new ROOM_NO, BED_NO combination exists
        if (bedNoInt != oldBedNoInt) {
            PreparedStatement dupPs = con.prepareStatement("SELECT COUNT(*) FROM room_info WHERE room_no=? AND bed_no=?");
            dupPs.setInt(1, roomNoInt);
            dupPs.setInt(2, bedNoInt);
            ResultSet dupRs = dupPs.executeQuery();
            if (dupRs.next() && dupRs.getInt(1) > 0) {
                throw new Exception("Room Number " + roomNoInt + " with Bed Number " + bedNoInt + " already exists.");
            }
            dupRs.close();
            dupPs.close();

            // Check if bed is assigned to a patient
            PreparedStatement patientPs = con.prepareStatement("SELECT COUNT(*) FROM patient_info WHERE room_no=? AND bed_no=?");
            patientPs.setInt(1, roomNoInt);
            patientPs.setInt(2, oldBedNoInt);
            ResultSet patientRs = patientPs.executeQuery();
            if (patientRs.next() && patientRs.getInt(1) > 0) {
                throw new Exception("Cannot update bed number; bed is assigned to a patient.");
            }
            patientRs.close();
            patientPs.close();
        }

        // Assign charges based on room type
        int charges;
        String typeTrim = type.trim();
        switch (typeTrim) {
            case "Common":
                charges = 2000;
                break;
            case "Deluxe":
                charges = 5000;
                break;
            case "ICU":
                charges = 10000;
                break;
            default:
                charges = 2000;
        }

        // Update room_info
        PreparedStatement ps = con.prepareStatement("UPDATE room_info SET bed_no=?, status=?, type=?, charges=? WHERE room_no=? AND bed_no=?");
        ps.setInt(1, bedNoInt);
        ps.setString(2, status);
        ps.setString(3, type);
        ps.setInt(4, charges);
        ps.setInt(5, roomNoInt);
        ps.setInt(6, oldBedNoInt);

        int i = ps.executeUpdate();
        if (i > 0) {
%>
<div style="text-align:center;margin-top:25%">
<font color="blue">
<script type="text/javascript">
function Redirect() {
    window.location="room.jsp";
}
document.write("<h2>Room with Bed Updated Successfully</h2><br><br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
        } else {
            throw new Exception("Room Not Updated. Check Room and Bed Number.");
        }
        ps.close();
    } catch (Exception e) {
%>
<div style="text-align:center;margin-top:25%">
<font color="red">
<script type="text/javascript">
function Redirect() {
    window.location="room.jsp";
}
document.write("<h2>Error: <%=e.getMessage()%></h2><br><br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
    }
%>