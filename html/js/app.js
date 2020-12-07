$(".container").hide()
window.addEventListener("message", (e) => {
    const data = e.data;
    if (data.action == "enable") {
        $(".container").fadeIn()
        
    } else if (data.action == "close") {
        $.post("http://cm-scoreboard/close", JSON.stringify({}))
        $(".container").hide()
    } else if (data.action == "update") {
        $(".players").html("")
        $(".jobs").html("")
        $(".players").append(`
            <span id="player">Your ID: ${data.playerID} || OnlinePlayers: ${data.connected} / ${data.maxPlayers} || Your Ping: ${data.playerPing}</span>
        `)
    }
     else if (data.action == "updateJobs") {
        $(".jobs").append(`
            <span id="jobs">EMS: <span style="color: red;">${data.jobs.EMS}</span> / LSPD: <span style="color: red;">${data.jobs.LSPD}</span> / MECHANIC: <span style="color: red;">${data.jobs.MECHANIC}</span></span>
        `)
    }
})