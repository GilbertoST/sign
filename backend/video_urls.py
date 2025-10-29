"""
URLs des vidéos YouTube LSF
Crédit: Dicoplus LSF - https://www.youtube.com/@DicoplusLSF
"""

# URLs YouTube pour chaque lettre
YOUTUBE_VIDEOS = {
    'A': 'https://www.youtube.com/watch?v=iaMgkWDgJJw',
    'B': 'https://www.youtube.com/watch?v=Zh4heDJgBpc',
    'C': 'https://www.youtube.com/watch?v=nFbH4lLluYg',
    'D': 'https://www.youtube.com/watch?v=Vpw6jcbz5ok',
    'E': 'https://www.youtube.com/watch?v=k2Fn2dF-YnI',
    'F': 'https://www.youtube.com/watch?v=LWveOz3FH7M',
    'G': 'https://www.youtube.com/watch?v=CsQl6gMoztM',
    'H': 'https://www.youtube.com/watch?v=PUaav-mmBn4',
    'I': 'https://www.youtube.com/watch?v=XRBPx4DR5Ss',
    'J': 'https://www.youtube.com/watch?v=qOY6kCXaSjo',
    'K': 'https://www.youtube.com/watch?v=o7n9aE_JqiY',
    'L': 'https://www.youtube.com/watch?v=67-SUPi7Ss4',
    'M': 'https://www.youtube.com/watch?v=FiXSCDqrwh0',
    'N': 'https://www.youtube.com/watch?v=5-FCqtndQC0',
    'O': 'https://www.youtube.com/watch?v=nbWQY6yiSSg',
    'P': 'https://www.youtube.com/watch?v=53qUbd__k_U',
    'Q': 'https://www.youtube.com/watch?v=jxix67BPQLA',
    'R': 'https://www.youtube.com/watch?v=1Ajn55lz7ic',
    'S': 'https://www.youtube.com/watch?v=8FXwPygUsvc',
    'T': 'https://www.youtube.com/watch?v=_7b3CcMUN6w',
    'U': 'https://www.youtube.com/watch?v=OrHe3h5uVJM',
    'V': 'https://www.youtube.com/watch?v=_TuV6YBz-3w',
    'W': 'https://www.youtube.com/watch?v=8vBxquS-kDA',
    'X': 'https://www.youtube.com/watch?v=_OLWqOmgqHY',
    'Y': 'https://www.youtube.com/watch?v=Rjv0bnT3usA',
    'Z': 'https://www.youtube.com/watch?v=vTrBvMTHKKg',
}

# Crédit de la chaîne
CREDIT = {
    'channel': 'Dicoplus LSF',
    'url': 'https://www.youtube.com/@DicoplusLSF'
}


def get_video_url(letter: str) -> str:
    """Retourne l'URL YouTube pour une lettre"""
    return YOUTUBE_VIDEOS.get(letter.upper(), '')


def get_image_url(letter: str) -> str:
    """Retourne l'URL de l'image locale pour une lettre"""
    return f"/assets/images/{letter.lower()}.png"


def extract_video_id(url: str) -> str:
    """Extrait l'ID d'une vidéo YouTube depuis son URL"""
    import re
    # Formats supportés: watch?v=ID ou youtu.be/ID
    match = re.search(r'(?:watch\?v=|youtu\.be/)([a-zA-Z0-9_-]{11})', url)
    if match:
        return match.group(1)
    return ''


def get_youtube_thumbnail_url(url: str) -> str:
    """Retourne l'URL de la miniature YouTube (format HD)"""
    video_id = extract_video_id(url)
    if video_id:
        return f"https://img.youtube.com/vi/{video_id}/maxresdefault.jpg"
    return ''



