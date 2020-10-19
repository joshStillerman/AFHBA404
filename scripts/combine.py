import numpy as np
import argparse
import json


def get_args():
    parser = argparse.ArgumentParser(description='THOMSON data mux tool.')
    parser.add_argument('--json_file', type=str,
                        default="ACQPROC/configs/7_uut_thom.json")
    args = parser.parse_args()
    return args


def load_json(json_file):
    with open(json_file) as _json_file:
        json_data = json.load(_json_file)
    return json_data


def get_uut_info(uut_json):
    uuts = []
    longwords = 0
    for uut in uut_json["AFHBA"]["UUT"]:
        uuts.append(uut["name"])
        longwords = int(uut["VI"]["SP32"]) + int((uut["VI"]["AI16"]) / 2)
    return longwords, uuts


def main():
    args = get_args()
    uut_json = load_json(args.json_file)
    longwords, uuts = get_uut_info(uut_json)

    data = []
    for uut in uuts:
        uut_data = np.fromfile("{}_VI.dat".format(
            uut), dtype=np.int32).reshape((-1, 112))
        data.append(uut_data)

    total_data = np.concatenate(data, axis=1).flatten()
    # hardcoded for thomson_analysis.py
    total_data.tofile("LLCONTROL/afhba.0.log")


if __name__ == '__main__':
    main()
