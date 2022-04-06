terraform output generated_ssh_private_key | egrep -v "EOT$|^$" > key && chmod 600 key
ssh -l opc -i key $(terraform output PublicIPs | head -2 | tail -1 | sed -e "s/[\" ,]//g")
