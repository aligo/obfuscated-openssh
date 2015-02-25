#	$OpenBSD: proxy-connect.sh,v 1.7 2014/05/03 18:46:14 dtucker Exp $
#	Placed in the Public Domain.

tid="proxy connect"

mv $OBJ/sshd_proxy $OBJ/sshd_proxy.orig

for ps in no yes; do
  cp $OBJ/sshd_proxy.orig $OBJ/sshd_proxy
  echo "UsePrivilegeSeparation $ps" >> $OBJ/sshd_proxy

  for p in 1 2; do
    for c in no yes; do
	verbose "plain username protocol $p privsep=$ps comp=$c"
	opts="-$p -oCompression=$c -F $OBJ/ssh_proxy"
	SSH_CONNECTION=`${SSH} $opts 999.999.999.999 'echo $SSH_CONNECTION'`
	if [ $? -ne 0 ]; then
		fail "ssh proxyconnect protocol $p privsep=$ps comp=$c failed"
	fi
	if [ "$SSH_CONNECTION" != "UNKNOWN 65535 UNKNOWN 65535" ]; then
		fail "bad SSH_CONNECTION protocol $p privsep=$ps comp=$c"
	fi
    done
  done
done

for p in 1 2; do
	verbose "username with style protocol $p"
	${SSH} -$p -F $OBJ/ssh_proxy ${USER}:style@999.999.999.999 true || \
		fail "ssh proxyconnect protocol $p failed"
done
