"""PIP installer for csce3513_project"""

from setuptools import setup, find_packages


setup(
    name="CSCE 3513 Project",
    version="0.1.0",
    author="Luke Simmons",
    author_email="luke5083@live.com",
    description="Hackathon Spring 2023 backend server.",
    url="https://github.com/Skyluker4/HackathonSpring2023",
    packages=find_packages(),
    classifiers=[
        'Development Status :: 1 - Planning',
        "Programming Language :: Python :: 3 :: Only",
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: POSIX :: Linux',
        'Environment :: GUI',
        'Intended Audience :: Education',
        'Natural Language :: English',
        'Topic :: Education',
    ],
    python_requires='>=3.9',
    platforms=[
        'Linux',
        'MacOS X',
        'Windows'
    ],
    license='GNU Affero General Public License v3 (AGPLv3)'
)
