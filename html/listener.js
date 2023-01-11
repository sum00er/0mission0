$(window).ready(function () {
    window.addEventListener('message', function (event) {
        let data = event.data
        if (data.toggle) {
            $("body").fadeIn()
            $('.mission').html(mission(data.mission))
        }
        if (data.close) {
            $("body").fadeOut()
        }
        if (data.update) {
            let mid = data.mission
            let circle = (1 - data.percent) * 144;
            $('.cm' + mid).css('stroke-dashoffset', circle);
            $('.mpercent' + mid).text(Math.round(data.percent * 100) + '%');
            $('.txt' + mid).text(data.ratio);
            if (data.finish) {
                $('.await-' + mid).prop('disabled', false);
                $('.await-' + mid).html(data.locale.get + '<span class="sucess-notice' + id + ' position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"><span class="visually-hidden">New alerts</span></span>')
                $('.await-' + mid).addClass('sucess-btn position-relative').removeClass('.await-' + mid);
            }
        }
        function mission(mission) {
            let html = ''
            let missionData = JSON.parse(mission)

            for (let i = 0; i < missionData.length; i++) {
                let status = ''
                id = missionData[i].mission_id
                progress = missionData[i].progress / missionData[i].max
                progresscircle = (1 - progress) * 144
                progresspercent = Math.round(progress * 100) + '%'
                if (missionData[i].finish == 0) {
                    status = '<button type="button" class="btn btn-danger mt-1 await-' + id + '" data-mid="' + id + '" disabled>' + data.locale.get + '</button>'
                } else if (missionData[i].finish == 1) {
                    status = '<button type="button" class="sucess-btn btn btn-danger mt-1 position-relative" data-mid="' + id + '" data-got = "' + data.locale.got + '">' + data.locale.get + '<span class="sucess-notice' + id + ' position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle"><span class="visually-hidden">New alerts</span></span></button>'
                } else {
                    status = '<button type="button" class="btn btn-secondary mt-1 position-relative p-1" disabled>' + data.locale.got + '</span></button>'
                }

                html += '<div class="mcard"><div class="row justify-content-md-center align-items-center"><div class="col-2">'
                html += '<svg class="circle" width="60" height="60"><circle class="progressplayer cm' + id + '" stroke="#ff8080" stroke-width="2.0" fill="rgba(177, 177, 177, 0.7)" style="stroke-opacity: 1.0" r="23" cx="24" cy="24" stroke-dasharray="144 144" stroke-dashoffset="' + progresscircle + '" />'
                html += '<text x="23" y="40" fill="white" style="font-size: 12px;" text-anchor="middle" class="mpercent' + id + '">' + progresspercent + '</text></svg></div>'
                html += '<div class="col-6"><div class="mtitle mt-1" style="font-size: 16px;"><b>' + missionData[i].title + '</b><span class="badge bg-secondary mdetail text-light txt' + id + '" style="font-size: 8px;">' + missionData[i].progress + '/' + missionData[i].max + '</span></div></div>'
                html += '<div class="col-3">' + status + '</div></div></div>'
            }

            return html
        }
        $(".sucess-btn").click(function () {
            let mid = $(this).data('mid')
            let got = $(this).data('got')
            $.post('https://0mission0/reward', JSON.stringify({ Id: mid }));
            $(this).prop('disabled', true);
            $(this).removeClass('btn-danger');
            $(this).addClass('btn-secondary p-1');
            $(this).text(got);
        })
    })
    document.onkeyup = function (data) {
        if (data.keyCode == 27) {
            $.post('https://0mission0/close', '{}');
        }
    }
})