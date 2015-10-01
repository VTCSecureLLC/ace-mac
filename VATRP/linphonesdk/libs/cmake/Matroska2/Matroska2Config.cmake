############################################################################
# Matroska2Config.cmake
# Copyright (C) 2015  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
############################################################################
#
# Config file for the Matroska2 package.
# It defines the following variables:
#
#  MATROSKA2_FOUND - system has Matroska2
#  MATROSKA2_INCLUDE_DIRS - the Matroska2 include directory
#  MATROSKA2_LIBRARIES - The libraries needed to use Matroska2
#  MATROSKA2_CPPFLAGS - The cflags needed to use Matroska2

get_filename_component(MATROSKA2_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} PATH)
set(MATROSKA2_INCLUDE_DIRS
	${MATROSKA2_CMAKE_DIR}/../../../include
)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
	set(MATROSKA2_LIBRARIES ${MATROSKA2_CMAKE_DIR}/../../matroska2.lib ${MATROSKA2_CMAKE_DIR}/../../ebml2.lib ${MATROSKA2_CMAKE_DIR}/../../corec.lib)
else()
	set(MATROSKA2_LIBRARIES ${MATROSKA2_CMAKE_DIR}/../../libmatroska2.a ${MATROSKA2_CMAKE_DIR}/../../libebml2.a ${MATROSKA2_CMAKE_DIR}/../../libcorec.a)
endif()

set(MATROSKA2_CPPFLAGS)
set(MATROSKA2_FOUND 1)
