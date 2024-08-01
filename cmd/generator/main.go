package main

import (
	"crypto/rand"
	"fmt"
	"os"
)

func main() {
	var (
		err          error
		file         *os.File
		bytesWritten int
	)
	const fileSize = 8 * 1024 * 1024 * 1024

	file, err = os.Create("8Gb.bin")
	if err != nil {
		fmt.Println("Ошибка при создании файла:", err)
		return
	}
	defer file.Close()

	const bufferSize = 1024 * 1024
	buffer := make([]byte, bufferSize)

	var totalBytesWritten int64

	for totalBytesWritten < fileSize {
		_, err = rand.Read(buffer)
		if err != nil {
			fmt.Println("Ошибка при генерации случайных данных:", err)
			return
		}

		bytesWritten, err = file.Write(buffer)
		if err != nil {
			fmt.Println("Ошибка при записи в файл:", err)
			return
		}

		totalBytesWritten += int64(bytesWritten)
	}

	fmt.Println("Файл успешно создан.")
}
