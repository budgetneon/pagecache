<?php
class ControllerModulePagecache extends Controller {
    private $error = array();

    public function pathindexphp() {
        $path=dirname(DIR_APPLICATION) .'/' . 'index.php';
        return $path; 
    }

    
    public function index() {
        // pull in all the language file entries
        $this->data = array_merge($this->data, $this->language->load('module/pagecache'));
        require_once(DIR_SYSTEM . 'library/pagecache.php');
        $pagecache = new PageCache();
        $vals=$pagecache->Settings();
        foreach (array_keys($vals) as $key) {
            if ($vals[$key] === true) {
                $vals[$key]='true';
            }
            if ($vals[$key] === false) {
                $vals[$key]='false';
            }
            $this->data[$key]=$vals[$key];
        }
        $this->document->setTitle($this->language->get('heading_title'));

        $this->data['breadcrumbs'] = array();
        $this->data['breadcrumbs'][] = array(
            'text'      => $this->language->get('text_home'),
            'href'      => $this->url->link('common/home', 'token=' . $this->session->data['token'], 'SSL'),
            'separator' => false
        );

        $this->data['breadcrumbs'][] = array(
            'text'      => $this->language->get('text_module'),
            'href'      => $this->url->link('extension/module', 'token=' . $this->session->data['token'], 'SSL'),
            'separator' => ' :: '
        );

        $this->data['breadcrumbs'][] = array(
            'text'      => $this->language->get('heading_title'),
            'href'      => $this->url->link('module/pagecache', 'token=' . $this->session->data['token'], 'SSL'),
            'separator' => ' :: '
        );

        $this->data['heading_title'] = $this->language->get('heading_title');
        $this->data['token'] = $this->session->data['token'];
        $this->template = 'module/pagecache.tpl';
        $this->children = array(
            'common/header',
            'common/footer'
        );
        $this->data['compatstatus']=$this->compatstatus();
        $this->response->setOutput($this->render());
    }
    public function stats() {
		$this->response->addHeader('Content-Type: application/json');
        require_once(DIR_SYSTEM . 'library/pagecache.php');
        $pagecache = new PageCache();
        $vals=$pagecache->Settings();
        $expire=$vals['expire'];
        $cachefolder=$vals['cachefolder'];
        $range=array( '0','1','2','3','4','5','6','7',
                      '8','9','a','b','c','d','e','f');
        $stats['totalf']=0;
        $stats['totalfe']=0;
        $stats['totalfv']=0;
        $stats['totalb']=0;
        $stats['totalbe']=0;
        $stats['totalbv']=0;
        foreach ($range as $f) {
            foreach ($range as $s) {
                $dname=$cachefolder . $f . '/' . $s;
                if (is_dir($dname) && @$dir=opendir($dname)) {
                    while (false !== ($file = readdir($dir))) {
                       $fpath=$dname . '/' . $file; 
                       if (is_file($fpath)) {
                           $fstats=stat($fpath);
                           $sizemb=number_format($fstats['size']/1048576,2);
                           $ctime=$fstats['ctime'];
                           $stats['totalb']+=$sizemb;
                           $stats['totalf']+=1;
                           if ($ctime+$expire < time()) {
                               $status='expired';
                               $stats['totalbe']+=$sizemb;
                               $stats['totalfe']+=1;
                           } else {
                               $status='valid';
                               $stats['totalbv']+=$sizemb;
                               $stats['totalfv']+=1;
                           }
                       }
                    }
                }
            }
        }
        $stats['totalb']=number_format($stats['totalb'],2);
        $stats['totalbe']=number_format($stats['totalbe'],2);
        $stats['totalbv']=number_format($stats['totalbv'],2);
        $stats['success']='ok';
        $this->response->setOutput(json_encode($stats));
    }
    public function isreadable() {
        $filepath=$this->pathindexphp();
        $dirpath=dirname($this->pathindexphp());
        if (!is_file($filepath)) {
            return array(false,"[$filepath] ". $this->language->get('pc_not_exist'));
        }
        if (!is_readable($filepath)) {
            return array(false,"[$filepath] " . $this->language->get('pc_not_readable'));
        }
        return array(true,"[$filepath] " . $this->language->get('pc_readable'));
    }
    public function iswriteable() {
        $filepath=$this->pathindexphp();
        $dirpath=dirname($this->pathindexphp());
        if (!is_writable($filepath)) {
            return array(false,"[$filepath] " . $this->language->get('pc_not_writeable'));
        }
        if (!is_writable($dirpath)) {
            return array(false,"[$dirpath] " . $this->language->get('pc_not_writeable'));
        }
        return array(true,"[$filepath] " . $this->language->get('pc_writeable'));
    }
    public function compatstatus() {
        if (version_compare(PHP_VERSION, '5.4.0') >= 0) {
             $phpcompat='supported (PHP 5.4 or greater)';
        } else {
             $phpcompat='unsupported (PHP 5.4 or greater is recommended)';
        }
        $phpsapi=php_sapi_name();
        if ($phpsapi == 'apache2handler') {
            $phpsapi='apache2handler (mod_php)';
            $sapicompat=$this->language->get('pc_sapi_mod_php');
        } elseif ($phpsapi == 'cgi-fcgi') {
            if (version_compare(PHP_VERSION, '5.4.0') >= 0) {
                $sapicompat=$this->language->get('pc_sapi_fcgi');
            } else {
                $sapicompat=$this->language->get('pc_sapi_fcgi_oldphp');
            }
        } elseif ($phpsapi == 'litespeed') {
                $sapicompat=$this->language->get('pc_sapi_litespeed');
        } else {
            $sapicompat=$this->language->get('pc_sapi_not_tested');
        }
        return "<table class='list'><thead>".
               "<tr><td class='left'>Component</td><td>Detected</td>".
               "<td class='left'>Status</td></tr></thead><tbody><tr>".
               "<td class='left'>PHP</td><td>" . phpversion() . "</td>".
               "<td class='left'>$phpcompat</td></tr>".
               "<tr><td class='left'>SAPI</td><td>" . $phpsapi . "</td>".
               "<td class='left'>$sapicompat</td></tr>".
               "</tbody></table>";
    }
    public function statusindexphp() {
        $this->language->load('module/pagecache');
        $check=$this->isreadable();
        if ($check[0] == false) {
            return $check;
        }
        $fp=fopen($this->pathindexphp(),'r');
        $pgcount=0;$topmarker=false;$bottommarker=false;
        $desiredcount=count($this->topcode()) + count($this->bottomcode());
        while(!feof($fp)) {
            $line=fgets($fp);
            if (preg_match('#^// Install\s*#',$line))  {
                $topmarker=true;
            }
            if (preg_match('#^\$response->output\(\);*#',$line))  {
                $bottommarker=true;
            }
            if (preg_match('/pagecache/i',$line)) {
                $pgcount++;
            } 
        }
        fclose($fp);
        if ($topmarker == false) {
            return(array('error',
                $this->language->get('pc_err_topmarker') 
            ));
        }
        if ($bottommarker == false) {
            return(array('error',
                $this->language->get('pc_err_bottommarker') 
            ));
        }
        if ($pgcount == 0) {
            return(array('disabled',$this->language->get('pc_pagecache_disabled')));
        } else if ($pgcount == $desiredcount) {
            return(array('enabled',$this->language->get('pc_pagecache_enabled')));
        } else {
            $error=sprintf($this->language->get('pc_count_error'),
                $pgcount,$desiredcount,$this->pathindexphp);
            return(array('error', $error));
        }
    }
    public function topcode() {
        return(array(
          'require_once(DIR_SYSTEM . \'library/pagecache.php\');' ,
          '$pagecache = new PageCache();' ,
          'if ($pagecache->ServeFromCache()) {' ,  
          '    // exit here if we served this page from the cache' ,
          '    return;',
          '}'
        ));
    }
    public function bottomcode() {
        return(array(
          'if ($pagecache->OkToCache()) {' ,
          '    $pagecache->CachePage($response);',
          '}'
        ));
    }
    public function enable() {
        $status=$this->statusindexphp();
        if ($status[0] == 'enabled') {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_already_enabled')) 
            ));
            return;
        } elseif ($status[0] == 'false') {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_enable_error') . $status[1]) 
            ));
            return;
        } elseif  ($status[0] != 'disabled') {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_enable_error') . $status[0]) 
            ));
            return;
        }
        $status=$this->iswriteable();
        if ($status[0] != true) {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_enable_error') . $status[1]) 
            ));
            return;
        }
        $tempfile=$this->pathindexphp() . '.tmp';
        $out=@fopen($tempfile,'w');
        $in=@fopen($this->pathindexphp(),'r');
        while(!feof($in)) {
            $line=fgets($in);
            if (preg_match('#^// Install\s*#',$line))  {
                foreach ($this->topcode() as $code) {
                    fwrite($out,str_pad($code,60) . "    //PAGECACHE\n");
                }
                fwrite($out,$line);
            } elseif (preg_match('#^\$response->output\(\);*#',$line))  {
                fwrite($out,$line);
                foreach ($this->bottomcode() as $code) {
                    fwrite($out,str_pad($code,60) . "    //PAGECACHE\n");
                }
            } else {
                fwrite($out,$line);
            }
        }
        fclose($out);
        fclose($in);
        rename($tempfile,$this->pathindexphp()); 
        // clear cache if apc is in use (in case apc.stat == 1)
        if (function_exists('apc_clear_cache')) {
            apc_clear_cache();
        } 
        $status=$this->statusindexphp();
        $this->response->setOutput(json_encode(
                array($status[0] => $status[1]) 
        ));
    }
    public function jsonstatusindexphp() {
        $status=$this->statusindexphp();
        $this->response->setOutput(json_encode(
                array('status' => $status[0],
                      'detail' => $status[1]
                ) 
        ));
    }
    public function disable($quiet=false) {
        $status=$this->statusindexphp();
        if ($status[0] == 'disabled') {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_already_disabled'))
            ));
            return;
        } elseif ($status[0] == 'false') {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_disable_error') . $status[1])
            ));
            return;
        } elseif  ($status[0] != 'enabled') {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_disable_error') . $status[0])
            ));
            return;
        }
        $status=$this->iswriteable();
        if ($status[0] != true) {
            $this->response->setOutput(json_encode(
                array('error' => $this->language->get('pc_disable_error') . $status[1])
            ));
            return;
        }
        $tempfile=$this->pathindexphp() . '.tmp';
        $out=@fopen($tempfile,'w');
        $in=@fopen($this->pathindexphp(),'r');
        while(!feof($in)) {
            $line=fgets($in);
            if (!preg_match('#//PAGECACHE#',$line))  {
                fwrite($out,$line);
            } 
        }
        fclose($out);
        fclose($in);
        rename($tempfile,$this->pathindexphp());
        // clear cache if apc is in use (in case apc.stat == 1)
        if (function_exists('apc_clear_cache')) {
            apc_clear_cache();
        } 
        $status=$this->statusindexphp();
        if ($quiet == false) {
            $this->response->setOutput(json_encode(
                array($status[0] => $status[1]) 
            ));
        }
    }

    public function purge() {
        $this->language->load('module/pagecache');
        $which=$this->request->get['which'];
        if ($which != "all" && $which != "expired") {
           $this->response->setOutput(json_encode(
                array('error' => 'invalid value for which')
           ));
           return;
        }
        require_once(DIR_SYSTEM . 'library/pagecache.php');
        $pagecache = new PageCache();
        $vals=$pagecache->Settings();
        $expire=$vals['expire'];
        $cachefolder=$vals['cachefolder'];
        $range=array( '0','1','2','3','4','5','6','7',
                      '8','9','a','b','c','d','e','f');
        $count=0;
        foreach ($range as $f) {
            foreach ($range as $s) {
                $dname=$cachefolder . $f . '/' . $s;
                if (is_dir($dname) && @$dir=opendir($dname)) {
                    while (false !== ($file = readdir($dir))) {
                       // only purge files that end in .cache
                       if (substr($file,-6) == '.cache') {
                           $fpath=$dname . '/' . $file;
                           if ($which == 'all') {
                               unlink($fpath);
                               $count++;
                           } elseif ($which == 'expired') {
                               if (filectime($fpath)+$expire < time()) {
                                   unlink($fpath);
                                   $count++;
                               }
                           }
                       }
                    }
                }
            }
        }
        $message=sprintf($this->language->get('pc_purged'),$count);
        $this->response->setOutput(json_encode(
            array('success' => $message)
        ));
    }

    protected function validate() {
        if (!$this->user->hasPermission('modify', 'module/pagecache')) {
            $this->error['warning'] = $this->language->get('error_permission');
        }
        if (!$this->error) {
            return true;
        } else {
            return false;
        }
    }

    public function install() {
        $this->load->model('setting/setting');
        $settings = $this->model_setting_setting->getSetting('pagecache');
        $settings['pagecache_show_menu'] = 1;
        $this->model_setting_setting->editSetting('pagecache', $settings);
    }

    public function uninstall() {
        $this->disable(true);
        $this->load->model('setting/setting');
        $settings = $this->model_setting_setting->getSetting('pagecache');
        $settings['pagecache_show_menu'] = 0;
        $this->model_setting_setting->editSetting('pagecache', $settings);
    }
}
?>
