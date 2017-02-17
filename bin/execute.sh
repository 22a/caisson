echo "language:"
echo $1
echo "time limit:"
echo $2
echo "memory limit:"
echo $3
echo "payload:"
echo $4

echo "output:"
docker run -i --rm python python -c "$4"
