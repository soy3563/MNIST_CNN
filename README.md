https://github.com/vipinkmenon/SpatialFilter
https://daechu.tistory.com/9

https://gin-girin-grim.tistory.com/10
https://devyihyun.tistory.com/30
https://developer0809.tistory.com/30


28*28의 MNIST를 읽어와서 CNN연산으로 확인하기
signed multiplier > 8bit로 63~-64
https://colab.research.google.com/drive/1TDNXGhXUclOtrLfN20YUpPfvm8GvMOKh?usp=sharing 
코랩 저걸로 테스트하니까 말도안되는 결과 나왔다.
313/313 [==============================] - 2s 4ms/step - loss: 23.0289 - accuracy: 0.1152
[23.028928756713867, 0.1151999980211258]
정규화하고 양자화할때 특수한 옵션이 더 필요할것 같다.. 이부분 그냥 맏기고 진행해야할듯, 임시로 내가 만든 가중치 바이어스로 제작해서
10개중에 1개 찾는지 테스트해보는걸로 하자. 건하형꺼 나오기 전에

예상문제 >> BMP 파일은뒤집히는데, 아 생각해보니까 학습을 BMP로 시킨게 아니네. 그니까 저 bmp 읽어와서 뒤집어서 테스트벤치에 넣는 방향으로 연산 진행하면 될 듯하다.

630 KB >> B-ram spec

Model: "model"(50FC)
_________________________________________________________________
 Layer (type)                Output Shape              Param #   
=================================================================
 input_1 (InputLayer)        [(None, 28, 28, 1)]       0         
                                                                 
 conv2d (Conv2D)             (None, 14, 14, 16)        160       
                                                                 
 conv2d_1 (Conv2D)           (None, 7, 7, 32)          4640      
                                                                 
 flatten (Flatten)           (None, 1568)              0         
                                                                 
 dense (Dense)               (None, 50)                78450     
                                                                 
 dense_1 (Dense)             (None, 10)                510       
                                                                 
=================================================================
Total params: 83760 (327.19 KB)
Trainable params: 83760 (327.19 KB)
Non-trainable params: 0 (0.00 Byte)
_________________________________________________________________
313/313 [==============================] - 1s 4ms/step - loss: 0.1136 - accuracy: 0.9720
[0.11358004063367844, 0.972000002861023]


FC layer 한개 추가하는게 훨씻 나아보임, 50개가 적당히 좋아보임 97퍼선에 나오고 비교해보니까 저정도 있어야 정확도 보장되는듯, 더 올리려면 출력을 PC로 보내고 하는 방식으로 해야될듯
0 > 25 : 92.44 > 96.47
25 > 50 : 96.47 > 97.20
50 > 50+25 : 97.20 > 97.14
50 > 25+25 : 97.20 > 96.86
50 > 100 : 97.20 > 97.83
100 > 200 : 97.83 > 97.53

Model: "model_1"(200FC)
_________________________________________________________________
 Layer (type)                Output Shape              Param #   
=================================================================
 input_3 (InputLayer)        [(None, 28, 28, 1)]       0         
                                                                 
 conv2d_2 (Conv2D)           (None, 14, 14, 16)        160       
                                                                 
 conv2d_3 (Conv2D)           (None, 7, 7, 32)          4640      
                                                                 
 flatten_1 (Flatten)         (None, 1568)              0         
                                                                 
 dense_1 (Dense)             (None, 200)               313800    
                                                                 
 dense_2 (Dense)             (None, 10)                2010      
                                                                 
=================================================================
Total params: 320610 (1.22 MB)
Trainable params: 320610 (1.22 MB)
Non-trainable params: 0 (0.00 Byte)
_________________________________________________________________
313/313 [==============================] - 1s 4ms/step - loss: 0.1044 - accuracy: 0.9753
[0.1044076532125473, 0.9753000140190125]


Model: "model"(100FC)
_________________________________________________________________
 Layer (type)                Output Shape              Param #   
=================================================================
 input_1 (InputLayer)        [(None, 28, 28, 1)]       0         
                                                                 
 conv2d (Conv2D)             (None, 14, 14, 16)        160       
                                                                 
 conv2d_1 (Conv2D)           (None, 7, 7, 32)          4640      
                                                                 
 flatten (Flatten)           (None, 1568)              0         
                                                                 
 dense (Dense)               (None, 100)               156900    
                                                                 
 dense_1 (Dense)             (None, 10)                1010      
                                                                 
=================================================================
Total params: 162710 (635.59 KB)
Trainable params: 162710 (635.59 KB)
Non-trainable params: 0 (0.00 Byte)
_________________________________________________________________
313/313 [==============================] - 1s 4ms/step - loss: 0.0989 - accuracy: 0.9783
[0.09886028617620468, 0.9782999753952026]

Model: "model"(25FC)
_________________________________________________________________
 Layer (type)                Output Shape              Param #   
=================================================================
 input_1 (InputLayer)        [(None, 28, 28, 1)]       0         
                                                                 
 conv2d (Conv2D)             (None, 14, 14, 16)        160       
                                                                 
 conv2d_1 (Conv2D)           (None, 7, 7, 32)          4640      
                                                                 
 flatten (Flatten)           (None, 1568)              0         
                                                                 
 dense (Dense)               (None, 25)                39225     
                                                                 
 dense_1 (Dense)             (None, 10)                260       
                                                                 
=================================================================
Total params: 44285 (172.99 KB)
Trainable params: 44285 (172.99 KB)
Non-trainable params: 0 (0.00 Byte)
_________________________________________________________________
313/313 [==============================] - 1s 4ms/step - loss: 0.1215 - accuracy: 0.9647
[0.12145102769136429, 0.9646999835968018]

Model: "model"(0FC)
_________________________________________________________________
 Layer (type)                Output Shape              Param #   
=================================================================
 input_1 (InputLayer)        [(None, 28, 28, 1)]       0         
                                                                 
 conv2d (Conv2D)             (None, 14, 14, 16)        160       
                                                                 
 conv2d_1 (Conv2D)           (None, 7, 7, 32)          4640      
                                                                 
 flatten (Flatten)           (None, 1568)              0         
                                                                 
 dense (Dense)               (None, 10)                15690     
                                                                 
=================================================================
Total params: 20490 (80.04 KB)
Trainable params: 20490 (80.04 KB)
Non-trainable params: 0 (0.00 Byte)
_________________________________________________________________
313/313 [==============================] - 1s 4ms/step - loss: 0.2750 - accuracy: 0.9244
[0.2749924659729004, 0.9243999719619751]

