#!/bin/bash



# Variables 
root=$(id -u)


function ctrl_c(){
 echo -e "\n[!] Saliendo del programa...\n"
 exit 1
}

trap ctrl_c SIGINT



# Control de flujo del programa

function update(){

  read -p "[?] ¿Qué distribución de Linux tienes (parrot, kali, arch, fedora)? -> " os
  case $os in
    parrot)
        echo -e "\n[*] Actualizando Sistema... [*]" && sudo apt update -y &> /dev/null && parrot-upgrade -y >& /dev/null && echo -e "\n[+] Sistema Operativo Actualizado con éxito [+]"
        ;;
    kali)
        echo -e "\n[*] Actualizando Sistema... [*]" && sudo apt update && apt upgrade -y >/dev/null && echo -e "\n[+] Sistema Operativo Actualizado con éxito [*]"
        ;;
    arch)
        echo -e "\n[*] Actualizando Sistema... [*]" && sudo pacman -Syu && echo -e "\n[+] Sistema Operativo Actualizado con éxito [+]"
        ;;
    fedora)
        echo -e "\n[*] Actualizando Sistema... [*]" && sudo dnf upgrade -y && echo -e "\n[+] Sistema Operativo Actualizado con éxito [*]"
       ;;
     *)
        echo -e "\n[!] No haz ingresado ninguna de las opciones dadas. [!]"
       ;;
  esac
}

function red_scan(){

 echo -e "\n[+] Escaneando Puertos [+]"
 for i in $(seq 1 254); do
   for port in 21 22 23 25 80 443 445 8080; do 
     timeout 1 bash -c "echo '' > /dev/tcp/192.168.0.$i/$port" 2>/dev/null && echo -e "\n [+] Host 192.168.0.$i - Port $port (OPEN) [+]" &
   done
 done
 wait
   echo -e "\n[*] Red y Puertos escaneados con éxito [*]"
}
   
function host_active(){
  
  echo -e "\n --> [+] Descubriendo Host Activos [+]<--"
  for i in $(seq 1 254); do
    timeout 1 bash -c "ping -c 1 192.168.0.$i" &>/dev/null && echo -e "\n [+] Host 192.168.0.$i - ACTIVE [+]" &
  done
  wait
}


function sistema_operativo(){
 
  read -p "--> Ingresa la IP de la cual deseas averiguar que Sistema Operativo tiene: " host

  if ping -c 1 $host >/dev/null; then
    echo -e "\n[*] Descubriendo Sistema...[*]\n"
    sleep 2
    TTL=$(ping -c 1 $host | awk '/ttl=/{print $6}' | tr -d "ttl=")
    echo -e "\n[*] Su TTL es de --> $TTL"
    if [ $TTL -gt 60 ] && [ $TTL -lt 70 ]; then
      echo -e "\n[+] Entonces es un Sistema Operativo Linux"
    elif [ $TTL -gt 100 ] && [ $TTL -lt 140 ]; then
      echo -e "\n[*] Entones es un Sistema Operativo Windows"
    else
      echo -e "\n[!] No se pudo determinar el sistema operativo"
    fi
  fi
}


if [ $root -ne 0 ]; then
  echo -e "\n[!] Debes ejecutar el programa como root [!]\n"
  exit 1
fi
read -p "--> Si quieres actualizar tu sistema digita: 'update' | Si quieres descubrir host y sus puertos abiertos digita: 'scan' | Si quieres saber el sistema operativo de un host digita: 'os': " usuario
if [ $usuario == 'update' ]; then
  update
elif [ $usuario == 'scan' ]; then
  host_active
  red_scan
elif [ $usuario == 'sistem' ]; then
  system_op
elif [ $usuario == 'os' ]; then
  sistema_operativo
else 
  echo -e "\n [!] Nos haz proporcionado una opción dada [!]"
fi
