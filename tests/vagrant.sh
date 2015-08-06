vagrant destroy -f infra1 infra2 infra3 proxy1 control1 hyper1

vagrant up infra1 &
sleep 10
vagrant up infra2 &
sleep 10
vagrant up infra3 &
sleep 10

vagrant up proxy1 &
sleep 10
vagrant up control1 &
sleep 10
vagrant up hyper1 &
