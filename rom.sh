#!/bin/bash

  detect_images() {
      local image_files=($(ls -1 *.img 2>/dev/null))
      if [ ${#image_files[@]} -eq 0 ]; then
          echo "Error: No image files found in the current directory."
          exit 1
      fi
      echo "Detected image files:"
      for ((i=0; i<${#image_files[@]}; i++)); do
          echo "$(($i+1)). ${image_files[$i]}"
      done
      read -p "Enter the number of the image file: " image_number
      if [ "$image_number" -ge 1 ] && [ "$image_number" -le ${#image_files[@]} ]; then
          selected_image=${image_files[$(($image_number-1))]}
          echo "Selected image: $selected_image"
      else
          echo "Invalid selection. Please enter a valid number."
          exit 1
      fi
  }

Mount() {
    current_size=$(du -m "$selected_image" | awk '{print $1}')
    e2fsck -f "$selected_image"
    fixed_size=500
    new_size=$((current_size + fixed_size))
    resize2fs "$selected_image" "${new_size}M"
    mkdir "./mounted-${selected_image%.img}"
    sudo mount -o rw "$selected_image" "./mounted-${selected_image%.img}"
}

Unmount() {
    sudo umount "./mounted-${selected_image%.img}"
    rm -r "./mounted-${selected_image%.img}"
    e2fsck -f "$selected_image"
    resize2fs -M "$selected_image"
}

Resize() {
    read -p "Enter the new size for $selected_image in megabytes: " size
    if [[ "$size" =~ ^[0-9]+$ ]]; then
        current_size=$(du -m "$selected_image" | awk '{print $1}')
        new_size=$((current_size + size))
        resize2fs "$selected_image" "${new_size}M"
        echo "Resized $selected_image to $current_size megabytes."
    else
        echo "Invalid size. Please enter a valid number."
    fi
}

Zip() {
    read -p "Enter the new size for $selected_image in megabytes: " size
    if [[ "$size" =~ ^[0-9]+$ ]]; then
        current_size=$(du -m "$selected_image" | awk '{print $1}')
        new_size=$((current_size + size))
        resize2fs "$selected_image" "${new_size}M"
        echo "Resized $selected_image to $current_size megabytes."
    else
        echo "Invalid size. Please enter a valid number."
    fi
}

Flash() {
    adb reboot fastboot
    partition_name="${selected_image%.img}"
    fastboot flash "$partition_name" "$selected_image"
    paplay ./winsquare-6993.mp3

}


DoingFlags=false


while getopts ":cps:d" opt; do
    case $opt in
        p)
            DoingFlags=true
            filename="${@: -1}"  
            numeric_permissions=$(stat -c "%a" "$filename")
            echo "Numeric permissions for $filename: $numeric_permissions"
            ;;
        s)
            DoingFlags=true
            filename="${@: -1}"  
            shift $((OPTIND - 1)) 
            permissions="$OPTARG"
            if [[ ! "$permissions" =~ ^[0-7]{3}$ ]]; then
                echo "Invalid permissions value: $permissions. It must be a three-digit octal number." >&2
                exit 1
            fi
            sudo chmod "$permissions" "$filename"
            echo "Changed permissions for $filename to $permissions."
            ;;
        d)
            DoingFlags=true
            sudo pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY dolphin "$(pwd)"
            ;;
        c)
            DoingFlags=true
            folder_name="oneUI6"
            rm -rf "$folder_name"
            cp -r ./zipTemplate "$folder_name"


            img2simg ./vendor.img  ./"$folder_name"/vendor.sparse
            echo 4 | img2sdat -o ./"$folder_name"/images -p vendor ./"$folder_name"/vendor.sparse
            vendor_size=$(( $(wc -c < ./vendor.img) + 10240 ))
            rm ./"$folder_name"/vendor.sparse
            brotli -q 5 ./"$folder_name"/images/vendor.new.dat -o ./"$folder_name"/images/vendor.new.dat.br
            rm ./"$folder_name"/images/vendor.new.dat

            img2simg ./system.img ./"$folder_name"/system.sparse
            echo 4 | img2sdat -o ./"$folder_name"/images -p system ./"$folder_name"/system.sparse
            system_size=$(( $(wc -c < ./system.img) + 10240 ))
            rm ./"$folder_name"/system.sparse
            brotli -q 5 ./"$folder_name"/images/system.new.dat -o ./"$folder_name"/images/system.new.dat.br
            rm ./"$folder_name"/images/system.new.dat

            img2simg ./product.img ./"$folder_name"/product.sparse
            echo 4 | img2sdat -o ./"$folder_name"/images -p product ./"$folder_name"/product.sparse
            product_size=$(( $(wc -c < ./product.img) + 10240 ))
            rm ./"$folder_name"/product.sparse
            brotli -q 5 ./"$folder_name"/images/product.new.dat -o ./"$folder_name"/images/product.new.dat.br
            rm ./"$folder_name"/images/product.new.dat

            img2simg ./odm.img ./"$folder_name"/odm.sparse
            echo 4 | img2sdat -o ./"$folder_name"/images -p odm ./"$folder_name"/odm.sparse
            odm_size=$(( $(wc -c < ./odm.img) + 10240 ))
            rm ./"$folder_name"/odm.sparse
            brotli -q 5 ./"$folder_name"/images/odm.new.dat -o ./"$folder_name"/images/odm.new.dat.br
            rm ./"$folder_name"/images/odm.new.dat

            img2simg ./prism.img ./"$folder_name"/prism.sparse
            echo 4 | img2sdat -o ./"$folder_name"/images -p prism ./"$folder_name"/prism.sparse
            prism_size=$(( $(wc -c < ./prism.img) + 10240 ))
            rm ./"$folder_name"/prism.sparse
            brotli -q 5 ./"$folder_name"/images/prism.new.dat -o ./"$folder_name"/images/prism.new.dat.br
            rm ./"$folder_name"/images/prism.new.dat

            img2simg ./optics.img ./"$folder_name"/optics.sparse
            echo 4 | img2sdat -o ./"$folder_name"/images -p optics ./"$folder_name"/optics.sparse
            optics_size=$(( $(wc -c < ./optics.img) + 10240 ))
            rm ./"$folder_name"/optics.sparse
            brotli -q 5 ./"$folder_name"/images/optics.new.dat -o ./"$folder_name"/images/optics.new.dat.br
            rm ./"$folder_name"/images/optics.new.dat

            output_file="./$folder_name/shared/op_list"
            echo "resize system $system_size" > "$output_file"
            echo "resize vendor $vendor_size" >> "$output_file"
            echo "resize odm $odm_size" >> "$output_file"
            echo "resize product $product_size" >> "$output_file"



            echo "File '$output_file' created successfully."


            cd "$folder_name" && zip -r ../"$folder_name".zip ./* && cd -
            paplay ./winsquare-6993.mp3

            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done


if [ "$DoingFlags" = true ]; then
  exit 0
fi

detect_images


echo "Select an option:"
echo "1. Mount"
echo "2. Unmount"
echo "3. Resize"
echo "4. Flash"


read -p "Enter your choice (1, 2, 3, or 4): " choice

case $choice in
    1) Mount ;;
    2) Unmount ;;
    3) Resize ;;
    4) Flash ;;
    *) echo "Invalid choice. Please enter 1, 2, or 3." ;;
esac
