<?php echo $header; ?>
<div id="content">
  <div class="breadcrumb">
    <?php foreach ($breadcrumbs as $breadcrumb) { ?>
      <?php echo $breadcrumb['separator']; ?><a href="<?php echo $breadcrumb['href']; ?>"><?php echo $breadcrumb['text']; ?></a>
    <?php } ?>
  </div>
  <div class="box">
    <div class="heading">
      <h1><?php echo $heading_title; ?></h1>
    </div>
    <div class="content">
      <div id="statuswrapper">
        <h2><?php echo $pc_text_status; ?><span id="modulestatus" style="display: inline-block; padding: 2px 4px; margin-left: 8px; background-color: #DDDDDD; color: #333333; border: 1px solid #333333;"><?php print $pc_wait;?></span></h2>
        <div id="understandwrapper" class="attention" style="font-size: 1.2em;">
            <span id="modulestatusdetail" style="font-weight: bold;"><?php print $pc_wait;?></span> <?php print $pc_enable_warn;?>
            <div style="text-align: center; margin-top: 10px;"><strong><input id="confirmstatus" type="checkbox" onclick="understand();"><label for="confirmstatus"><?php echo $pc_understand; ?></label></strong><br /><a id="changestatus" class="button" style="margin-top: 5px; font-size: 1.2em; pointer-events: none; opacity: 0.5;"><?php print $pc_wait;?></a></div>
        </div>
      </div>
      <div id="statwrapper" style="margin-top: 50px;">
       <h2><?php print $pc_header_cachestat;?></h2>
        <table class='list'>
          <thead>
            <tr>
              <td class='left'><?php print $pc_td_cf;?></td>
              <td class='left'><?php print $pc_td_total;?></td>
              <td class='left'><?php print $pc_td_space;?></td>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class='left'><?php print $pc_td_valid;?></td>
              <td class='left' id="totalfv"><?php print $pc_wait;?></td>
              <td class='left'><span id='totalbv'><?php print $pc_wait;?></span> MB</td>
            </tr>
            <tr>
              <td class='left'><?php print $pc_td_expired;?></td>
              <td class='left' id="totalfe"><?php print $pc_wait;?></td>
              <td class='left'><span id='totalbe'><?php print $pc_wait;?></span> MB</td>
            <tr>
              <td class='left'><?php print $pc_td_total;?></td>
              <td class='left' style='font-weight:bold;' id="totalf"><?php print $pc_wait;?></td>
              <td class='left'><span id='totalb'><?php print $pc_wait;?></span> MB</td>
            </tr>
          </tbody>
        </table>
        <div class="buttons" style="text-align: center;">
          <a id="refreshstats" class="button"><?php print $pc_btn_refresh;?></a> &nbsp;<a id="purgeall" class="button"><?php print $pc_btn_purge;?></a> &nbsp;<a id="purgeexpired" class="button"><?php print $pc_btn_purgeexp;?></a>
        </div>
      </div>
      <div id="compatwrapper" style="margin-top: 50px;">
        <h2><?php echo $pc_label_compat; ?></h2>
        <div id='compatstatus'><?php print $compatstatus;?></div>
      </div>
      <div id="settingswrapper" style="margin-top: 50px;">
        <h2><?php print $pc_header_settings;?></h2>
        <div class="settingnote attention"><?php print $pc_settings_note;?></div>
        <table class='list'>
          <thead>
            <tr>
              <td class='left'><?php print $pc_td_setting;?></td>
              <td class='left'><?php print $pc_td_value;?></td>
              <td class='left'><?php print $pc_td_detail;?></td>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class='left'>cachefolder</td><td class='left'><?php echo $cachefolder;?></td>
              <td class='left'><?php print $pc_cachefolder_note;?></td>
            </tr>
            <tr>
              <td class='left'>expire</td><td class='left'><?php echo $expire;?></td>
              <td class='left'><?php print $pc_expire_note;?></td>
            </tr>
            <tr>
              <td class='left'>lang</td><td class='left'><?php echo $lang;?></td>
              <td class='left'><?php print $pc_lang_note;?></td>
            </tr>
            <tr>
              <td class='left'>currency</td><td class='left'><?php echo $currency;?></td>
              <td class='left'><?php print $pc_currency_note;?></td>
            </tr>
            <tr>
              <td class='left'>addcomment</td><td class='left'><?php echo $addcomment;?></td>
              <td class='left'><?php print $pc_addcomment_note;?></td>
            </tr>
            <tr>
              <td class='left'>wrapcomment</td><td class='left'><?php echo $wrapcomment;?></td>
              <td class='left'><?php print $pc_wrapcomment_note;?></td>
            </tr>
            <tr>
              <td class='left'>end_flush</td><td class='left'><?php echo $end_flush;?></td>
              <td class='left'><?php print $pc_end_flush_note;?></td>
            </tr>
            <tr>
              <td class='left'>cachebydevice</td><td class='left'><?php echo $cachebydevice;?></td>
              <td class='left'><?php print $pc_cachebydevice_note;?></td>
            </tr>
            <tr>
              <td class='left'>skip_urls</td>
              <td class='left'><?php echo join('<br>',$skip_urls);?></td>
              <td class='left'><?php print $pc_skipurls_note;?></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
<script type="text/javascript">
function understand() {
  if ($('#confirmstatus').is(':checked')) {
    $('#changestatus').css('pointer-events', 'auto').fadeTo("fast",1.0);
  } else {
    $('#changestatus').css('pointer-events', 'none').fadeTo("fast",0.5);
  }
}
function showstatus() {
 $( document ).ready(function() {
      $.ajax({
          url: 'index.php?route=module/pagecache/jsonstatusindexphp'+
               '&token=<?php echo $token; ?>',
                type: 'get',
                dataType: 'json',
                success: function(json) {
                   $('#changestatus').fadeOut;
                   $('#modulestatus').html(json['status']);                
                   $('#modulestatusdetail').html(json['detail']);                
                   $('#changestatus').unbind( "click" );
                   if (json['status'] == 'enabled') {
                      $('#modulestatus').css("background-color","#9CE824")
                      $('#changestatus').text('<?php print $pc_btn_disable;?>');
                      $('#changestatus').click(function(){disablemod();});
                   } else if (json['status']=='disabled') {
                      $('#changestatus').text('<?php print $pc_btn_enable;?>');
                      $('#modulestatus').css("background-color","#FCCB0A")
                      $('#changestatus').click(function(){enablemod();});
                      $('#changestatus').prop('disabled',false);
                   } else {
                      alert(json['status']);
                      $('#modulestatus').css("background-color","#D9534F")
                      $('#changestatus').prop('disabled',true);
                   }
                   
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    // 200 ok, with ajax error probably expired admin session
                    if (xhr.status == 200) {
                        alert('admin session expired? reloading page');
                        location.reload();
                    } else {
                        alert('ajax load error: ' + xhr.status +
                              'error [' + thrownError + ']');
                    }
                }

      });
  });
}
function enablemod() {
  $( document ).ready(function() {
      $.ajax({
          url: 'index.php?route=module/pagecache/enable'+
               '&token=<?php echo $token; ?>',
                type: 'get',
                dataType: 'json',
                beforeSend: function(){
                    if (!$('#confirmstatus').is(':checked')) {
                        // for browsers without pointer-events support
                        alert('Please backup index.php then click "I understand ..." in order to enable Page Caching.');
                        return false;
                    }
                    $('#changestatus').prop('disabled',true);
                    $('#changestatus').fadeTo("slow",0.5);
                },
                success: function(json) {
                    if (json['error']) {
                        alert(json['error']);
                    }
                    $('#confirmstatus').prop('checked',false);
                    $('#changestatus').prop('disabled',false);
                    showstatus();
                    understand();
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    // 200 ok, with ajax error probably expired admin session
                    if (xhr.status == 200) {
                        alert('admin session expired? reloading page');
                        location.reload();
                    } else {
                        alert('ajax load error: ' + xhr.status +
                              'error [' + thrownError + ']');
                    }
                }

      });
  });
}
function disablemod() {
  $( document ).ready(function() {
      $.ajax({
          url: 'index.php?route=module/pagecache/disable'+
               '&token=<?php echo $token; ?>',
                type: 'get',
                dataType: 'json',
                beforeSend: function(){
                    if (!$('#confirmstatus').is(':checked')) {
                        // for browsers without pointer-events support
                        alert('Please backup index.php then click "I understand ..." in order to disable Page Caching.');
                        return false;
                    }
                    $('#changestatus').prop('disabled',true);
                    $('#changestatus').fadeTo("slow",0.5);
                },
                success: function(json) {
                    if (json['error']) {
                        alert(json['error']);
                    }
                    $('#confirmstatus').prop('checked',false);
                    $('#changestatus').prop('disabled',false);
                    showstatus();
                    understand();
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    // 200 ok, with ajax error probably expired admin session
                    if (xhr.status == 200) {
                        alert('admin session expired? reloading page');
                        location.reload();
                    } else {
                        alert('ajax load error: ' + xhr.status +
                              'error [' + thrownError + ']');
                    }
                }

      });
  });
}
function fillstats() {
  $( document ).ready(function() {
      $.ajax({
          url: 'index.php?route=module/pagecache/stats'+
               '&token=<?php echo $token; ?>',
                type: 'get',
                dataType: 'json',
                success: function(json) {
                    var items=[ 'totalfv','totalbv', 'totalfe',
                    'totalbe', 'totalf','totalb'];
                    for (var i=0;i<items.length;i++) {
                        var item=items[i];
                        $('#'+item).fadeOut();
                        $('#'+item).html(json[item]);
                        $('#'+item).fadeIn();
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    // 200 ok, with ajax error probably expired admin session
                    if (xhr.status == 200) {
                        alert('admin session expired? reloading page');
                        location.reload();
                    } else {
                        alert('ajax load error: ' + xhr.status +
                              'error [' + thrownError + ']');
                    }
                }
      });
  });
}
function purge(which) {
    $( document ).ready(function() {
        $.ajax({
            url: 'index.php?route=module/pagecache/purge'+
               '&which='+which+
               '&token=<?php echo $token; ?>',
            type: 'get',
            dataType: 'json',
            beforeSend: function() {
                $('#purgeall').prop('disabled',true);
                $('#purgeexpired').prop('disabled',true);
                $('#purgeall').fadeTo('slow',0.5);
                $('#purgeexpired').fadeTo('slow',0.5);
            },
            complete: function() {
                $('#purgeall').prop('disabled',false);
                $('#purgeexpired').prop('disabled',false);
                $('#purgeall').fadeTo('fast',1);
                $('#purgeexpired').fadeTo('fast',1);
            },
            success: function(json) {
              alert(json['success']);
              fillstats();
            },
            error: function (xhr, ajaxOptions, thrownError) {
                // 200 ok, with ajax error probably expired admin session
                if (xhr.status == 200) {
                    alert('admin session expired? reloading page');
                    location.reload();
                } else {
                    alert('ajax load error: ' + xhr.status +
                          'error [' + thrownError + ']');
                }
            }

      });
  });
}
$( document ).ready(function() {
    $( "#purgeall" ).click(function() {
        purge('all');
    });
    $( "#purgeexpired" ).click(function() {
        purge('expired');
    });
    $( "#refreshstats" ).click(function() {
        $('#refreshstats').prop('disabled',true);
        $('#refreshstats').fadeTo("slow",0.5);
        fillstats();
        $('#refreshstats').prop('disabled',false);
        $('#refreshstats').fadeTo("fast",1);
    });
    showstatus();
    fillstats();
    understand();
});
</script>
<?php echo $footer; ?>
