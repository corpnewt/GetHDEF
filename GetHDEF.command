#!/usr/bin/python
import os, subprocess, shlex, datetime, sys, pprint

os.chdir(os.path.dirname(os.path.realpath(__file__)))

def run_command(comm, shell = False):
    c = None
    try:
        if shell and type(comm) is list:
            comm = " ".join(shlex.quote(x) for x in comm)
        if not shell and type(comm) is str:
            comm = shlex.split(comm)
        p = subprocess.Popen(comm, shell=shell, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        c = p.communicate()
        return (c[0].decode("utf-8", "ignore"), c[1].decode("utf-8", "ignore"), p.returncode)
    except:
        if c == None:
            return ("", "Command not found!", 1)
        return (c[0].decode("utf-8", "ignore"), c[1].decode("utf-8", "ignore"), p.returncode)

def cls():
   	os.system('cls' if os.name=='nt' else 'clear')

def head(text = "One Script", width = 55):
    cls()
    print("  {}".format("#"*width))
    mid_len = int(round(width/2-len(text)/2)-2)
    middle = " #{}{}{}#".format(" "*mid_len, text, " "*((width - mid_len - len(text))-2))
    if len(middle) > width+1:
        # Get the difference
        di = len(middle) - width
        # Add the padding for the ...#
        di += 3
        # Trim the string
        middle = middle[:-di] + "...#"
    print(middle)
    print("#"*width)

def custom_quit():
    head()
    print("by CorpNewt\n")
    print("Thanks for testing it out, for bugs/comments/complaints")
    print("send me a message on Reddit, or check out my GitHub:\n")
    print("www.reddit.com/u/corpnewt")
    print("www.github.com/corpnewt\n")
    # Get the time and wish them a good morning, afternoon, evening, and night
    hr = datetime.datetime.now().time().hour
    if hr > 3 and hr < 12:
        print("Have a nice morning!\n\n")
    elif hr >= 12 and hr < 17:
        print("Have a nice afternoon!\n\n")
    elif hr >= 17 and hr < 21:
        print("Have a nice evening!\n\n")
    else:
        print("Have a nice night!\n\n")
    exit(0)

def get_hdef(hdef):
    # First split up the text and find the device
    try:
        hid = "HDEF@" + hdef.split("HDEF@")[1].split()[0]
    except:
        return None
    # Got our HDEF address - get the full info
    hd = run_command(["ioreg", "-p", "IODeviceTree", "-n", hid])[0]
    if not len(hd):
        return None
    primed = False
    hdevice = {"name":"Unknown", "parts":{}}
    for line in hd.split("\n"):
        if not primed and not "HDEF@" in line:
            continue
        if not primed:
            # Has HDEF
            try:
                hdevice["name"] = "HDEF@" + line.split("HDEF@")[1].split()[0]
            except:
                hdevice["name"] = "Unknown"
            primed = True
            continue
        # Primed, but not HDEF
        if "+-o" in line:
            # Past our prime
            primed = False
            continue
        # Primed, not HDEF, not next device - must be info
        try:
            name = line.split(" = ")[0].split('"')[1]
            hdevice["parts"][name] = line.split(" = ")[1]
        except Exception as e:
            pass
    return hdevice

def ptrunc(text, length = 80):
    if len(text) > length:
        text = text[:length-3]+"..."
    print(text)

def main():
    max_length = 80
    head("Get HDEF")
    print("")
    ioreg = run_command(["ioreg"])
    if not len(ioreg[0]):
        print("IOReg error!")
        exit(1)
    hdef = []
    for line in ioreg[0].split("\n"):
        if "HDEF" in line:
            hdef.append(line)
    if not len(hdef):
        print("HDEF not found!")
        exit(1)
    # Iterate through our HDEFs and get the info
    hlist = []
    for h in hdef:
        d = get_hdef(h)
        if d:
            hlist.append(d)
    # Print!
    for h in hlist:
        # Get the PciRoot location
        try:
            locs = h['name'].split("@")[1].split(",")
            loc = "PciRoot(0x0)/Pci(0x{},0x{})".format(locs[0],locs[1])
        except:
            loc = None
            pass
        if loc:
            print("{} - {}:\n".format(h['name'], loc))
        else:
            print("{}:\n".format(h['name']))
        # Get the longest key
        longest = max(map(len, h['parts']))
        for k in h["parts"]:
            v = h['parts'][k]
            ptrunc("{} = {}".format(" "*(longest-len(k))+k, v))
        print("")


if __name__ == '__main__':
    main()
