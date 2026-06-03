from yolotracker.core import ObjectDetector
from yolotracker.config import DetectorConfig

def test_load_onnx_models():
    detector_config = DetectorConfig(
        detection_model_path='./weights/yolox_s.onnx',
        reid_model_path='./weights/osnet_x0_25_msmt17.onnx',
        weapon_model_path='./weights/yolox_s_weapon_merged.onnx',
        detection_shape=(640, 640),
        detection_thr=0.5,
        weapon_thr=0.5,
        onnx_provider='cpu',
        warmup_frames=30,
        min_area_percentage=0.005,
    )

    detector = ObjectDetector(config=detector_config)
