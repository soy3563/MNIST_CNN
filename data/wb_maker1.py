# 파일에서 데이터 읽어오기
def read_data_from_file(filename):
    data = []
    with open(filename, 'r') as file:
        for line in file:
            parts = line.strip().split(',')
            bias = float(parts[0].split('=')[1].strip())
            weights = [float(w.strip()) for w in parts[1].split('=')[1].strip(' []').split()]
            data.append({'bias': bias, 'weights': weights})
    return data

# 데이터 블록을 생성하는 함수
def generate_data_block(bias, weights):
    block = f"{bias:.4f}, normalized weights = ["
    weights_str = " ".join(f"{w:.4f}" for w in weights)
    block += f" {weights_str} ]"
    return block

# 파일에 데이터 쓰기
def write_data_to_file(filename, data):
    with open(filename, 'w') as file:
        for i, entry in enumerate(data):
            file.write(f"   conv1_bias[{(i+1)*8-1}:{i*8}] <= 8'b{int(entry['bias']):08b}; //normalized bias={entry['bias']:.4f}\n")

            weights_str = ""
            for w in entry['weights']:
                weights_str += f"{int(w):08b}_"
            weights_str = weights_str[:-1]  # 마지막의 언더스코어 제거

            file.write(f"   conv1_weight[{(i+1)*72-1}:{i*72}] <= 72'b{weights_str};\n")


# 파일에서 데이터 읽어오기
filename = 'conv1Layer.txt'  # 실제 파일 이름으로 변경해주세요
data = read_data_from_file(filename)

# 데이터 출력
#rearrange_and_print_data(data)

filename_write = 'WB1.txt'  # 결과를 저장할 파일 이름으로 변경해주세요
write_data_to_file(filename_write, data)
