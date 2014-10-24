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
    <h2>Status</h2>
    <div>
    <span style='font-weight:bold;font-size: larger;'><?php print $pc_label_status;?></span>
    <span id='modulestatus' style='display:inline-block;margin: 0 3pt;padding: 3pt;background-color: #ddd;font-weight: bold;font-size: larger;text-transform: uppercase;border: 1px solid #000;'><?php print $pc_wait;?></span> 
    (<span id='modulestatusdetail'><?php print $pc_wait;?></span>)
    </div>
    <div style='margin-top: 5pt;'>
    <div style='font-weight:bold;font-size: larger;'>
      <?php print $pc_label_compat;?></div>
      <span id='compatstatus'><?php print $compatstatus;?></span> 
    </div><br>
    <a id="changestatus" class="button"><?php print $pc_wait;?></a>
    <div style="margin: 10pt;padding: 5pt;border: 1px solid #ccc;">
        <?php print $pc_enable_warn;?>
    </div>
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
    <a id="refreshstats" class="button"><?php print $pc_btn_refresh;?></a>
    <div></div><br>
    <h2><?php print $pc_header_ops;?></h2>
    <a id="purgeall" class="button"><?php print $pc_btn_purge;?></a>&nbsp;&nbsp;
    <a id="purgeexpired" class="button"><?php print $pc_btn_purgeexp;?></a>
    <div></div><br>
    <h2><?php print $pc_header_settings;?></h2>
    <span><?php print $pc_settings_note;?></span>
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
      <td class='left'>skip_urls</td>
      <td class='left'><?php echo join('<br>',$skip_urls);?></td>
      <td class='left'><?php print $pc_skipurls_note;?></td>
    </tbody>
    </table>
    </div>
  </div>
</div>
<script>
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
                      $('#modulestatus').css("background-color","#009900")
                      $('#changestatus').text('<?php print $pc_btn_disable;?>');
                      $('#changestatus').click(function(){disablemod();});
                   } else if (json['status']=='disabled') {
                      $('#changestatus').text('<?php print $pc_btn_enable;?>');
                      $('#modulestatus').css("background-color","#ECE300")
                      $('#changestatus').click(function(){enablemod();});
                      $('#changestatus').prop('disabled',false);
                   } else {
                      alert(json['status']);
                      $('#modulestatus').css("background-color","#dd0000")
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
                    $('#changestatus').prop('disabled',true);
                    $('#changestatus').fadeTo("slow",0.5);
                },
                success: function(json) {
                    if (json['error']) {
                        alert(json['error']);
                    }
                    $('#changestatus').prop('disabled',false);
                    $('#changestatus').fadeTo("fast",1.0);
                    showstatus();
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
                    $('#changestatus').prop('disabled',true);
                    $('#changestatus').fadeTo("slow",0.5);
                },
                success: function(json) {
                    if (json['error']) {
                        alert(json['error']);
                    }
                    $('#changestatus').prop('disabled',false);
                    $('#changestatus').fadeTo("fast",1.0);
                    showstatus();
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
});
</script>
<?php echo $footer; ?>
