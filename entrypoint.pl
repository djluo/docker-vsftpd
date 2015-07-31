#!/usr/bin/perl
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 2.0(20150107)
#
# 初衷: 每个容器用不同用户运行程序,已方便在宿主中直观的查看.
# 需求: 1. 动态添加用户,不能将添加用户的动作写死到images中.
#       2. 容器内尽量不留无用进程,保持进程树干净.
# 问题: 如用shell的su命令切换,会遗留一个su本身的进程.
# 最终: 使用perl脚本进行添加和切换操作. 从环境变量User_Id获取用户信息.

use strict;
#use English '-no_match_vars';

my $uid = 1000;
my $gid = 1000;

$uid = $gid = $ENV{'User_Id'} if $ENV{'User_Id'} =~ /\d+/;

unless (getpwuid("$uid")){
  system("/usr/sbin/useradd", "-U", "-u $uid", "-m", "docker");
}

unless ( -d "/var/run/vsftpd/empty"){
  system("mkdir", "-p", "/var/run/vsftpd/empty");
}

my $conf="/etc/vsftpd.conf";
if ( -f $conf && (stat($conf))[4] != 0 ){
  system("chown", "root.root", "$conf");
}

#system("rm", "-f", "/run/crond.pid") if ( -f "/run/crond.pid" );
#system("/usr/sbin/cron");
#
#my $min  = int(rand(60));
#my $hour = int(rand(5));
#system("mkdir", "-m", "700", "/mysql/backup") unless ( -d "/mysql/backup" );
#open (CRON,"|/usr/bin/crontab") or die "crontab error?";
#print CRON ("$min $hour * * * (/mysql/xtrab.sh backup >/mysql/backup/stdout.log 2>/mysql/backup/stderr.log)\n");
#close(CRON);

# 切换当前运行用户,先切GID.
#$GID = $EGID = $gid;
#$UID = $EUID = $uid;
#$( = $) = $gid; die "switch gid error\n" if $gid != $( ;
#$< = $> = $uid; die "switch uid error\n" if $uid != $< ;

# 在命令行末尾添加日志开关
my @cmd   = @ARGV;
if ( $ENV{'DEBUG'} =~ /YES$/){
  push @cmd, "/etc/vsftpd.conf";
  push @cmd, "-oxferlog_std_format=NO";
}

$ENV{'HOME'} = "/home/docker";

# 信号处理,无法自行回收
$SIG{TERM} = sub {
  my @proc = `ps -efw|grep vsftpd`;
  my $pid  = (split/\s+/,$proc[1])[1];
  system("kill", "$pid");
  print "kill $pid\n";
};

system(@cmd);
